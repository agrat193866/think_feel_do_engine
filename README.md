# Think Feel Do Engine

[![Build Status](https://travis-ci.org/cbitstech/think_feel_do_engine.svg)](https://travis-ci.org/cbitstech/think_feel_do_engine) [![security](https://hakiri.io/github/cbitstech/think_feel_do_engine/master.svg)](https://hakiri.io/github/cbitstech/think_feel_do_engine/master)

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

## ToDo
1) test for destroying lesson
2) Additional tests for now updating research content - i.e., managing tasks!
2) scope content to tool after I move in bit_core models
3) check for role on edit_task page (use CanCanCan), but you can't authorship content