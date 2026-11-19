ARG RUBY_VERSION=3.4
FROM ruby:${RUBY_VERSION}

# Gemfile to install: the default resolves the newest rack the Ruby supports, or pick
# gemfiles/rack_1.gemfile (the rack line the services run) or gemfiles/rack_2.gemfile.
ARG BUNDLE_GEMFILE=Gemfile
ENV BUNDLE_GEMFILE=${BUNDLE_GEMFILE}

# Minimum Bundler: 2.3.27 is the last release that supports Ruby 2.5, and the ruby:2.x
# images ship 1.17. Images that already have a newer Bundler keep it.
ARG BUNDLER_VERSION=2.3.27

WORKDIR /home/angus

COPY angus.gemspec Gemfile ./
COPY lib/angus/version.rb ./lib/angus/version.rb
COPY gemfiles ./gemfiles

RUN gem list -i bundler -v ">= ${BUNDLER_VERSION}" >/dev/null \
      || gem install bundler -v "${BUNDLER_VERSION}" --no-document
RUN bundle install

# Source is copied after the install so dependency changes are the only thing that
# invalidates the bundle layer. See .dockerignore for what stays out (lockfiles, .git).
COPY . .

# Leaves a shell; run the tests with:
#   docker run --rm angus bundle exec rspec
CMD ["/bin/bash"]
