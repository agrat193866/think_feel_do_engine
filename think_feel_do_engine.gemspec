$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem"s version:
require "think_feel_do_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "think_feel_do_engine"
  s.version     = ThinkFeelDoEngine::VERSION
  s.authors     = ["Eric Carty-Fickes"]
  s.email       = ["ericcf@northwestern.edu"]
  s.homepage    = "https://github.com/cbitstech/think_feel_do_engine"
  s.summary     = "Summary of ThinkFeelDoEngine."
  s.description = "Description of ThinkFeelDoEngine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*",
                "MIT-LICENSE",
                "Rakefile",
                "README.md"]

  s.add_dependency "rails", "~> 4.1"
  s.add_dependency "turbolinks", "~> 2.2"
  s.add_dependency "bit_core", "~> 1.2"
  s.add_dependency "bit_player", "~> 0.4"
  s.add_dependency "rails_admin", "~> 0.6"
  s.add_dependency "devise", "~> 3.2"
  s.add_dependency "cancan", "~> 1.6"
  s.add_dependency "strong_password", "~> 0"
  s.add_dependency "bootstrap-sass", "~> 3.1"
  s.add_dependency "sass-rails", "~> 4.0"
  s.add_dependency "underscore-rails", "~> 1.6"
  s.add_dependency "rickshaw_rails", "~> 1.4"

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~> 3.0"
  s.add_development_dependency "poltergeist", "~> 1.5"
  s.add_development_dependency "database_cleaner", "~> 1.3"
  s.add_development_dependency "jasmine-rails", "0.10.0"
end
