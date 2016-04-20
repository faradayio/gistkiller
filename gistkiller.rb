require 'bundler/setup'
require 'csv'
require 'json'
require 'time'
require 'digest/sha2'
require 'logger'
require 'gist'
require 'rest-client'

HISTORY_PATH = '.gistkiller-history.json'
ACCESS_TOKEN_PATH = "#{ENV.fetch('HOME')}/.gist"
LOGGER = Logger.new $stderr
LOGGER.level = Logger::WARN
LOGGER.formatter = proc do |severity, datetime, progname, msg|
   "#{msg}\n"
end
# RestClient.log = LOGGER

unless File.exists?(ACCESS_TOKEN_PATH)
  Gist.login!
end

ACCESS_TOKEN = IO.read(ACCESS_TOKEN_PATH).chomp
PER_PAGE = 10

all_gists = []
page = 1
loop do
  LOGGER.warn { "getting gists page #{page}..." }
  tries = 0
  begin
    response = RestClient.get("https://api.github.com/gists", params: { page: page, per_page: PER_PAGE, access_token: ACCESS_TOKEN })
    page_gists = JSON.parse response.body
    all_gists += page_gists
    break if page_gists.length < PER_PAGE
    page += 1
  rescue RestClient::ServiceUnavailable
    break
  end
end

all_gists = all_gists.sort_by do |g|
  Time.parse(g.fetch('updated_at') || g.fetch('created_at'))
end.reverse

history = if File.exists?(HISTORY_PATH)
  JSON.parse IO.read(HISTORY_PATH)
else
  {}
end

begin
  all_gists.each do |g|
    hashed_id = Digest::SHA256.hexdigest g.fetch('id') # so that your gistkiller history doesn't become a security risk
    puts
    puts '#' * 80
    puts '#' * 80
    puts '#' * 80

    if history[hashed_id] == 'kept'
      puts
      puts "skipping #{g.fetch('html_url')} because you already kept it"
      next
    end
    puts
    puts g.fetch('html_url')
    puts
    begin
      puts Gist.read_gist(g.fetch('id'))
    rescue RuntimeError
      if $!.message =~ /Gist with id of.*does not exist/
        LOGGER.warn { "api claims gist doesn't exist, sometimes this happens, trying a backup plan..." }
        raw_url = g.fetch('files').to_a.first.last.fetch('raw_url')
        response = RestClient.get raw_url
        puts response.body
      else
        raise
      end
    end
    puts
    $stdout.write "Delete? (y for yes, o to open, any other key to not delete) "
    resp = $stdin.gets.chomp
    if resp == 'o'
      system 'open', g.fetch('html_url')
      puts
      $stdout.write "Delete? (y for yes, any other key to not delete) "
      resp = $stdin.gets.chomp
    end
    case resp
    when 'y'
      $stdout.write "Deleting..."
      RestClient.delete "https://api.github.com/gists/#{g.fetch('id')}", params: { access_token: ACCESS_TOKEN }
      puts "OK"
    else
      history[hashed_id] = 'kept'
    end
  end
ensure
  LOGGER.info { "writing history to #{HISTORY_PATH}" }
  File.open(HISTORY_PATH, 'w') do |f|
    f.write JSON.dump(history)
  end
end
