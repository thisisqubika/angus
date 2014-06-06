![angus logo](http://moove-it.github.io/angus/angus_logo.png)


## What is Angus?

Angus is a REST-like API framework which fits perfectly with Ruby.
It is based on rack, so it can be used to complement an existing app or as standalone service to
easily develop RESTful APIs. It is a lightweight framework, with
special focus on simplicity. Angus is an excellent option for creating REST-like APIs

## Status

[![BuildStatus](https://api.travis-ci.org/Moove-it/angus.png)](https://travis-ci.org/Moove-it/angus) [![Gem Version](https://badge.fury.io/rb/angus.png)](http://badge.fury.io/rb/angus)

Angus is production-ready, but still under development. We are working hard to keep bringing new
features and fixing any bug that may appear.

## Project Page

[Angus Page] (http://moove-it.github.io/angus)

## Installation

Install Angus as a gem:

    gem install angus

If you are using bundler, add it to your Gemfile:

    gem 'angus'

Run `bundle install`.

## Angus Demo

Creating your first API using Angus is very simple. Just type on your terminal:

    angus demo

This command will create an API with two users. Run the API typing the following command on your console:

    angus server

Enter to the documentation typing this url on your favorite browser:

    http://localhost:9292/demo/doc/0.1

Also, try getting the resources typing these urls on the browser:

    http://localhost:9292/demo/api/0.1/users
    http://localhost:9292/demo/api/0.1/users/1

## Basic usage
You can see our wiki documentation - "Creating a new Project with Angus"
https://github.com/Moove-it/angus/wiki/Getting-Started


### Clients

A big bonus of using documented services is that you can easily create automated clients for it.
And with this in mind be have!

[angus-remote] (https://github.com/Moove-it/angus-remote) is a dynamic angus remote client generator.
So invoking angus applications is almost as easy (if not more) than developing an API with angus.

For example to get the users list exposed by angus demo, you just have to create 2 files:

remote_demo.rb
```ruby
require 'angus-remote'

remote_service = Angus::Remote::ServiceDirectory.lookup('demo', '0.1')

users = remote_service.get_users.users

users.each do |user|
  puts "#{user.id} => #{user.name}"
end
```
config/services.yml
```yml
demo:
  v0.1:
    api_url: http://localhost:9292/demo/api/0.1/
    doc_url: http://localhost:9292/demo/doc/0.1/
```

This is just a little example, for the full documentation visit [angus-remote GitHub page] (https://github.com/Moove-it/angus-remote)

### Versioning

API versioning with Angus is done by URL. This means that you can easily have more than one version
of you service running in the same url and do the corresponding redirection based in the requested
version.

Support for multiple versions in the same process was considered and even implemented but it was
later removed because it proved to be hard to maintain an app that had to expose multiple versions
in the same process.

But the version was kept in the url so that it was easy to have multiple process running with
different versions and have Nginx or Apache to invoke the right one.

## Contributing to Angus

We encourage you to submit pull requests, propose features and discuss issues. Just fork the
repository on your GitHub account, and code what you want!

## Wiki
https://github.com/Moove-it/angus/wiki

## License

MIT License. See [LICENSE] (https://github.com/Moove-it/angus/blob/master/LICENSE.txt) for details.

## Copyright

Copyright (c) 2010-2014 Moove-iT
