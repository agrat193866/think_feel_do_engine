begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

Bundler::GemHelper.install_tasks

git_tagger = Gem::Specification.find_by_name "git_tagger"
load "#{git_tagger.gem_dir}/lib/tasks/deploy.rake"

require "rspec/core"
require "rspec/core/rake_task"
 
desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)

desc "Run all JS specs"
task :js_spec do
  Rake::Task["app:spec:javascript"].invoke
end

require "jshintrb/jshinttask"
Jshintrb::JshintTask.new :jshint do |t|
  t.pattern = "spec/dummy/spec/javascripts/**/*.js"
  t.options = :defaults
  t.globals = ["$".to_sym, :spyOn, :afterEach, :beforeEach, :describe, :expect, :it, :jasmine, :sc]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Run Brakeman"
task :brakeman do
  dir = File.dirname(__FILE__)
  puts `#{ File.join(dir, "bin", "brakeman") } #{ File.join(dir, ".") }`
end

task :default do
  Rake::Task["brakeman"].invoke
  Rake::Task["jshint"].invoke
  Rake::Task["rubocop"].invoke
  Rake::Task["spec"].invoke
  Rake::Task["js_spec"].invoke
end
