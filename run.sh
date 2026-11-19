#!/bin/sh
# Builds the image for one Ruby and opens a shell in it with the source mounted.
#   RUBY_VERSION=2.6 BUNDLE_GEMFILE=gemfiles/rack_1.gemfile ./run.sh
# Only lib/ and spec/ are mounted: the Gemfile.lock and the installed gems stay
# the ones resolved inside the image for its Ruby. Changing dependencies needs a rebuild.
RUBY_VERSION=${RUBY_VERSION:-3.4}
BUNDLE_GEMFILE=${BUNDLE_GEMFILE:-Gemfile}
TAG="angus:${RUBY_VERSION}"

docker build \
  --build-arg RUBY_VERSION="$RUBY_VERSION" \
  --build-arg BUNDLE_GEMFILE="$BUNDLE_GEMFILE" \
  -t "$TAG" . || exit 1

docker run --rm -it \
  -v "${PWD}/lib:/home/angus/lib" \
  -v "${PWD}/spec:/home/angus/spec" \
  "$TAG" bash
