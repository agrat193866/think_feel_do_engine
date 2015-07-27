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

gem "devise", "~> 3.2"

gem "jquery-datatables-rails",
    tag: "v1.12.0",
    git: "https://github.com/rweng/jquery-datatables-rails.git"

gem "event_capture",
    tag: "0.1.1",
    git: "https://github.com/cbitstech/event_capture.git"

gem "bit_core",
    tag: "1.4.2",
    git: "https://github.com/cbitstech/bit_core.git"

gem "bit_player",
    tag: "0.4.9",
    git: "https://github.com/cbitstech/bit_player.git"

gem "git_tagger",
    tag: "1.1.8",
    git: "https://github.com/cbitstech/git_tagger.git"

gem "twilio-ruby", "~> 3.12"

group :development, :test do
  gem "jasmine-rails"
  gem "rubocop", "~> 0.26"
end

group :test do
  gem "timecop", "~> 0.7"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end
