# This file is copied to spec/ when you run "rails generate rspec:install"
ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../dummy/config/environment", __FILE__)
require "rspec/rails"
require "capybara/poltergeist"

Capybara.javascript_driver = :poltergeist
options = {
  js_errors: false,
  timeout: 180,
  phantomjs_options: ["--ignore-ssl-errors=true", "--local-to-remote-url-access=false"],
  window_size: [1024, 2000]
}
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, options)
end

require "database_cleaner"
# require "simplecov"
# SimpleCov.start do
#   add_group "Controllers", "app/controllers"
#   add_group "Mailers", "app/mailers"
#   add_group "Models", "app/models"
#   add_filter "spec/"
# end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{ File.dirname(__FILE__) }/support/**/*.rb"].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Defines fixed timepoint called in the before :suite and after :suite below
FIXED_TIMEPOINT = Time.local(2008, 9, 1, 10, 5, 0)

RSpec.configure do |config|
  config.include Rails.application.routes.url_helpers
  config.fixture_path = "#{ File.dirname(__FILE__) }/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before :suite do
    Timecop.travel FIXED_TIMEPOINT
  end

  config.after :suite do
    Timecop.return
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    # Timecop.return
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:all) do
    DeferredGarbageCollection.start
  end

  config.after(:all) do
    DeferredGarbageCollection.reconsider
  end
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.include AuthenticationHelpers, type: :feature
  config.include DeviseMailHelpers, type: :feature
end
