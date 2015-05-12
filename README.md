# Think Feel Do Engine

[![Build Status](https://travis-ci.org/cbitstech/think_feel_do_engine.svg)](https://travis-ci.org/cbitstech/think_feel_do_engine)
[![security](https://hakiri.io/github/cbitstech/think_feel_do_engine/master.svg)](https://hakiri.io/github/cbitstech/think_feel_do_engine/master)

Provides the tools and administrative interface for Think Feel Do.

## Installation

To add to a host Rails application, add to the `Gemfile`

    gem "think_feel_do_engine", git: "git@github.com:cbitstech/think_feel_do_engine.git"

then install

    bundle install

mount the routes within `config/routes.rb`

```ruby
Rails.application.routes.draw do
  mount ThinkFeelDoEngine::Engine => ""
end
```

Install the think_feel_do_engine migrations into the host application and run
them:

```console
rake think_feel_do_engine:install:migrations
rake db:migrate
```

Configure observers

```ruby
# config/application.rb

require "rails-observers"

class Application < Rails::Application
  config.active_record.observers = "bit_core/slide_observer"
end
```

## Run specs

Set up the database

    rake app:db:create app:db:migrate

run the specs

    ./bin/rake
