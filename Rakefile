begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ThinkFeelDoEngine'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

git_tagger = Gem::Specification.find_by_name "git_tagger"
load "#{git_tagger.gem_dir}/lib/tasks/deploy.rake"

require "rspec/core"
require "rspec/core/rake_task"
 
desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec => "app:db:test:prepare")
 
task default: :spec


Bundler::GemHelper.install_tasks

