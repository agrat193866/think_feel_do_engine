source "https://rubygems.org"

# Declare your gem"s dependencies in think_feel_do_engine.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem "debugger"

gem "bit_player", "~> 0.4"
gem "devise", "~> 3.2"
gem "event_capture",
    git: "https://github.com/cbitstech/event_capture.git",
    ref: "1f9a199"
gem "jquery-datatables-rails",
    tag: "v1.12.0",
    git: "https://github.com/rweng/jquery-datatables-rails.git"

gem "twilio-ruby", "~> 3.12"

group :test do
  gem "timecop", "~> 0.7"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end
