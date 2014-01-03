![angus logo](http://moove-it.github.io/angus/angus_logo.png)


## What is Angus?

Angus is a REST-like API framework which fits perfectly with Ruby.
It is based on rack, so it can be used to complement an existing app or as standalone service to
easily develop RESTful APIs. It is a lightweight framework, with
special focus on simplicity. Angus is an excellent option for creating REST-like APIs

## Status

Angus is production-ready but under development, we are working hard to keep bringing new features and fixing any bug that may appear.

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

This command will create an API with two users. Run the API typing on your console:

    angus server

Enter to the documentation typing this url on your favourite browser:

    http://localhost:9292/demo/doc/0.1

Also, try getting the resources typing these urls on the browser:

    http://localhost:9292/demo/api/0.1/users
    http://localhost:9292/demo/api/0.1/users/1

## Basic usage

If you want to create your own API, just type on the terminal the following command:

    angus new api-name

After creating the API, you should create one or more resources. Just type the following command to generate a full CRUD resource, in this case called `account`:

    angus scaffold account

Angus will generate two files, which completely define the resource inside your API.

 * resources/account.rb
 * definitions/accounts/operations.yml

The first one is a ruby class, with 5 actions, that matches with the RESTful approach of the resource. The content of this class is the following:

```ruby
class Accounts < Angus::BaseResource

  def create
  end

  def update
  end

  def destroy
  end

  def show
  end

  def index
  end

end
```
The second file handles the operations which the API will offer to the client:

```yml
create:
  name: 'create'
  description: ''
  path: 'accounts'
  method: 'post'

  uri:
    - element:
      description:

  response:
    - element: ''
      description: ''
      required:
      type:

  messages:
    - key:
      description: ''

update:
  name: 'update'
  description: ''
  path: 'accounts/:id'
  method: 'put'

  uri:
    - element:
      description:

  response:
    - element: ''
      description: ''
      required:
      type:

  messages:
    - key:
      description: ''

destroy:
  name: 'destroy'
  description: ''
  path: 'accounts/:id'
  method: 'delete'

  uri:
    - element:
      description:

  response:
    - element: ''
      description: ''
      required:
      type:

  messages:
    - key:
      description: ''

show:
  name: 'show'
  description: ''
  path: 'accounts/:id'
  method: 'get'

  uri:
    - element:
      description:

  response:
    - element: ''
      description: ''
      required:
      type:

  messages:
    - key:
      description: ''

index:
  name: 'index'
  description: ''
  path: 'accounts'
  method: 'get'

  uri:
    - element:
      description:

  response:
    - element: ''
      description: ''
      required:
      type:

  messages:
    - key:
      description: ''
```

Last, there is a base class for the API, called `api-name.rb` and a configuration file called `service.yml`, which has the following content:

```ruby
class Api < Angus::Base
  def configure
    register :accounts
  end
end
```

```yml
service:   'Api'
code_name: 'api'
version:   '0.1'
```

The first file, registers each resource in the API. Every time you create a new resource, executing `angus resource name`, a line is added into this file.
The second file is a configuration YAML which handles the API version, the name, and the code name.

### Rails

Place you API into `app/api/` and modify `application.rb`

```ruby
config.paths.add "app/api", glob: "**/*.rb"
config.autoload_paths += Dir["#{Rails.root}/app/api/*"]
```

Modify `config/routes`, to match with your API.

### Versioning

API versioning with Angus is done by URL. You can define more than one version in your API configuration file, and then, enter
to each one using the version inside the URL.

For example, if you have an API version 1.1, and an stable version named 1, you can enter to each one using:

```
/api/v1.1/resource
/api/v1/resource
```

## Contributing to Angus

We encourage you to submit pull requests, propose features and discuss issues. Just fork the repository on your Github account, and code what you want!" en vez de "Angus encouraged you to submit pull requests, propose features and discuss issues. Just fork the repository on your Github account, and code what you want!

## Copyright

Copyright (c) 2010-2014 Moove-IT
