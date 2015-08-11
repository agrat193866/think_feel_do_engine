namespace :test_databases do
  desc "Prepare test databases for parallel runs"
  task :prepare do
    puts "preparing test db 0..."
    `RAILS_ENV=test bundle exec rake db:drop db:create db:migrate`
    (1..2).each do |p|
      puts "preparing test db #{ p }..."
      `RAILS_ENV=test TEST_ENV_NUMBER=#{ p } bundle exec rake db:drop db:create db:migrate`
    end
  end
end
