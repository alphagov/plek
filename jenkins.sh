#!/bin/bash -x
set -e
rm -f Gemfile.lock
bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rake

cd go
go test -v
cd ..

if [[ -n "$PUBLISH_GEM" ]]; then
  bundle exec rake publish_gem
fi
