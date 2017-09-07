#!/bin/bash -x
set -e

for version in 2.1.8 2.2.4 2.3.1 2.4.0; do
  rm -f Gemfile.lock
  RBENV_VERSION=$version bundle install --path "${HOME}/bundles/${JOB_NAME}"
  RBENV_VERSION=$version bundle exec rake
done
