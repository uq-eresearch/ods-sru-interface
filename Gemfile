source 'https://rubygems.org'

gem 'sinatra'

# Use unicorn as the app server
gem 'unicorn'

gem 'activerecord'
gem 'redis' # Use redis as a compromise between in-memory & RDBMS for anon IDs
gem 'rake'
gem 'libxml-ruby'
gem 'nokogiri'
gem 'foreman'
gem 'clockwork'
gem 'equivalent-xml'
gem 'sanitize' # For stripping out HTML
gem 'bloomfilter-rb' # Needed for ID salt verification

gem 'idzebra', '>= 0.1.1'

group :test do
  gem 'rack-test'
  gem 'sqlite3' # For testing models
end

group :test, :development do
  gem 'rspec'
  gem 'minitest'
  gem 'simplecov', :require => false
  gem 'spork' # For running a test server (and spec_helper.rb refers to it)
  gem 'mock_redis' # Because we don't want to use redis during unit tests
end

group :development do
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'debugger'
  gem 'libnotify', :require => false unless RUBY_PLATFORM =~ /linux/i
  gem 'ruby-prof'
  gem 'shotgun'
end

group :oracle do
  gem 'ruby-oci8'
  gem 'activerecord-oracle_enhanced-adapter'
end
