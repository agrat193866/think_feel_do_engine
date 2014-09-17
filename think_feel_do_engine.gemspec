$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "think_feel_do_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "think_feel_do_engine"
  s.version     = ThinkFeelDoEngine::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ThinkFeelDoEngine."
  s.description = "TODO: Description of ThinkFeelDoEngine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.5"

  s.add_development_dependency "pg"
end
