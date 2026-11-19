![angus logo](http://moove-it.github.io/angus/images/angus_logo2.svg)


## What is Angus?

Angus is a REST-like API framework which fits perfectly with Ruby.
It is based on rack, so it can be used to complement an existing app or as standalone service to
easily develop RESTful APIs. It is a lightweight framework, with
special focus on simplicity. Angus is an excellent option for creating REST-like APIs

## Status

[![Gem Validations](https://github.com/thisisqubika/angus/actions/workflows/config.yml/badge.svg)](https://github.com/thisisqubika/angus/actions/workflows/config.yml) [![Gem Version](https://badge.fury.io/rb/angus.png)](http://badge.fury.io/rb/angus)

Angus is production-ready, but still under development. We are working hard to keep bringing new
features and fixing any bug that may appear.

## Getting Started

1. Install Angus if you haven't yet:

        gem install angus

2. At the command prompt, create a new Angus service:

        angus new myapp

   where "myapp" is the application name.

3. Change directory to `myapp`, run bundle and start the web server:

        cd myapp
        bundle
        angus server

4. Using a browser, go to `http://localhost:8080`

## Usage

You can see our wiki to get information on how to use angus:  [Angus Wiki] (https://github.com/moove-it/angus/wiki)

#### Useful links

 * [Demo] (https://github.com/moove-it/angus/wiki/Demo)
 * [Creating a new Project with Angus] (https://github.com/moove-it/angus/wiki/Getting-Started)
 * [Consume angus api] (https://github.com/moove-it/angus/wiki/Clients)
 * [Versioning] (https://github.com/moove-it/angus/wiki/Versioning)


## Development

### Running the tests with Docker

`Dockerfile` builds an image for any Ruby version and installs the gem dependencies in it:

    docker build --build-arg RUBY_VERSION=2.7 -t angus:2.7 .
    docker run --rm angus:2.7 bundle exec rspec

`BUNDLE_GEMFILE` selects the dependency set; the default is `Gemfile`, or pick one of
`gemfiles/*.gemfile` (`rack_1.gemfile` pins rack 1.6.13):

    docker build --build-arg RUBY_VERSION=3.4 --build-arg BUNDLE_GEMFILE=gemfiles/rack_1.gemfile -t angus:3.4 .

`./run.sh` builds the image and opens a shell with `lib/` and `spec/` mounted, so you can edit and
re-run the specs without rebuilding. It reads `RUBY_VERSION` and `BUNDLE_GEMFILE` from the environment:

    RUBY_VERSION=2.6 BUNDLE_GEMFILE=gemfiles/rack_1.gemfile ./run.sh

Coverage is written to `coverage/` (HTML and JSON) on every run.

### CI matrix

`.github/workflows/config.yml` runs on pull requests and on pushes to `master`. The `Run tests`
check passes only when every job of the matrix passed.

| Interpreter | Versions | rack |
|---|---|---|
| MRI | 2.5, 2.6, 2.7, 3.0, 3.1, 3.2, 3.3, 3.4 | 1.6.13 (`gemfiles/rack_1.gemfile`) |
| JRuby | 9.3.14.0, 9.4.1.0, 9.4.5.0 | 1.6.13 |

There is no rack 2 line: every published release of `angus-router` requires `rack ~> 1.5`.

Coverage is published by `bancardsa/coverage-action` from the MRI 3.4 job.

### Branches

`master` is the only long-lived branch. Point to it without a `branch:` option:

    gem 'angus', git: 'https://github.com/thisisqubika/angus.git'

Work on a ticket branch (`VS-123`) and open a pull request against `master`.

## Contributing to Angus

We encourage you to submit pull requests, propose features and discuss issues. Just fork the
repository on your GitHub account, and code what you want!

## License

MIT License. See [LICENSE] (https://github.com/moove-it/angus/blob/master/LICENSE.txt) for details.

## Copyright

Copyright (c) 2010-2014 Moove-it
