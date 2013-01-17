require 'rubygems'
Bundler.setup
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

require 'active_record'

def start_simplecov
  require 'simplecov'
  SimpleCov.start
end

Spork.prefork do
  # The Spork.prefork block is run only once when the spork server is started.
  # You typically want to place most of your (slow) initializer code in here, in
  # particular, require'ing any 3rd-party gems that you don't normally modify
  # during development.

  # SimpleCov initialisation, as demonstrated in:
  # https://github.com/colszowka/simplecov/issues/42#issuecomment-4440284
  start_simplecov unless ENV['DRB']

  require 'rspec/autorun'

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR,
    # uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"

    # Rollback the database between tests
    config.around do |example|
      ActiveRecord::Base.transaction do
        example.run
        raise ActiveRecord::Rollback
      end
    end

  end

  ENV['STAFF_ID_SECRET'] = 'test_environment_secret'
end

Spork.each_run do
  # The Spork.each_run block is run each time you run your specs.  In case you
  # need to load files that tend to change during development,
  # require them here.
  # With Rails, your application modules are loaded automatically, so sometimes
  # this block can remain empty.

  # SimpleCov initialisation
  start_simplecov if ENV['DRB']

  ActiveRecord::Base.establish_connection 'sqlite3://localhost/:memory:'
  ActiveRecord::Migrator.up "db/migrate"

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each {|f| require f}

  # Include models
  Dir[File.join(File.dirname(__FILE__), '..', 'models', '*.rb')].each {|f| require f}
end






