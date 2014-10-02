# Think Feel Do Engine

Provides the tools and administrative interface for Think Feel Do.

## Installation

To add to a host Rails application, add to the `Gemfile`

    gem "think_feel_do_engine", git: "git@github.com:cbitstech/think_feel_do_engine.git"

then install

    bundle install

mount the routes within `config/routes.rb`

    Rails.application.routes.draw do
      mount ThinkFeelDoEngine::Engine => ""
    end

## Run specs

Set up the database

    rake app:db:create app:db:migrate

run the specs

    rake spec
