# gistkiller

Helps you clean up your gists.

## Install

1. `git clone https://github.com/faradayio/gistkiller.git`
2. `cd gistkiller`
3. `bundle install`
4. `ruby gistkiller.rb`

## Usage

```ruby
ruby gistkiller.rb
```

On the first run, it will log you into gist via oauth2:

```
10:25:11 seamus@pirlo:~/code/gistkiller
$ ruby gistkiller.rb
Obtaining OAuth2 access_token from github.
GitHub username: seamusabshere
GitHub password:
2-factor auth code: 123456

Success! https://github.com/settings/applications
```

(stores the secret in ~/.gist)

Then you basically interactively decide whether to delete your gists.

## Known issues

Github's API returns a 503 on the last page of gists, instead of returning less than the pagination limit. Who knows. You may have to run this script multiple times to get all your gists.

## Sponsor

<p><a href="http://faraday.io"><img src="https://s3.amazonaws.com/faraday-assets/files/img/logo.svg" alt="Faraday logo"/></a></p>

## Copyright

Copyright 2016 Faraday
