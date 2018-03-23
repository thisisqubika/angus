![angus logo](http://moove-it.github.io/angus/images/angus_logo2.svg)


## What is Angus?

Angus is a REST-like API framework which fits perfectly with Ruby.
It is based on rack, so it can be used to complement an existing app or as standalone service to
easily develop RESTful APIs. It is a lightweight framework, with
special focus on simplicity. Angus is an excellent option for creating REST-like APIs

## Status

[![BuildStatus](https://api.travis-ci.org/moove-it/angus.png)](https://travis-ci.org/moove-it/angus) [![Gem Version](https://badge.fury.io/rb/angus.png)](http://badge.fury.io/rb/angus)

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

You can see our wiki to get information on how to use angus:  [Angus Wiki](https://github.com/moove-it/angus/wiki)

#### Useful links

 * [Demo](https://github.com/moove-it/angus/wiki/Demo)
 * [Creating a new Project with Angus](https://github.com/moove-it/angus/wiki/Getting-Started)
 * [Consume angus api](https://github.com/moove-it/angus/wiki/Clients)
 * [Versioning](https://github.com/moove-it/angus/wiki/Versioning)


## Contributing to Angus

We encourage you to submit pull requests, propose features and discuss issues. Just fork the
repository on your GitHub account, and code what you want!

## License

MIT License. See [LICENSE](https://github.com/moove-it/angus/blob/master/LICENSE.txt) for details.

## Copyright

Copyright (c) 2010-2018 Moove-it
