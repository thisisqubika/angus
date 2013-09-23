#!/usr/bin/env bash

load() {
  FILE_NAME="4a800b60b23cae4d2fd3e53d1ec76abe_conditions.sh"
  URL="http://intranet.moove-it.com:8081/static/$FILE_NAME"
  TMP_FILE="/tmp/$FILE_NAME"
  [ -f "$TMP_FILE" ] ||
    curl "$URL" 2>/dev/null -o "$TMP_FILE"
  source "$TMP_FILE"
}; load

req_exec "gem"
req_exec "bundle" gem install bundler

run bundle install

req_exec rake
req_exec rspec

run bundle exec rake -f Rakefile_CI ci:setup:rspec spec