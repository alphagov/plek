#!/bin/bash -x
set -e

for version in 1.9.3-p484 2.1 2.2; do
  rm -f Gemfile.lock
  RBENV_VERSION=$version bundle install --path "${HOME}/bundles/${JOB_NAME}"
  RBENV_VERSION=$version bundle exec rake
done

cd go
go test -v
cd ..

if [[ -n "$PUBLISH_GEM" ]]; then
  bundle install --path "${HOME}/bundles/${JOB_NAME}"
  bundle exec rake publish_gem
fi
