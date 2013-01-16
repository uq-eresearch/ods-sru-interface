desc "Console access with all models loaded."
task :console do
  Bundler.setup
  require 'active_record'

  # To handle use of cattr_accessor in oracle_enhanced_adapter
  require 'active_support/all'
  require 'active_record/connection_adapters/oracle_enhanced_adapter'
 
  # Include models
  Dir[File.join(File.dirname(__FILE__), '..', '..', 'models', '*.rb')].each {|f| require f}
  
  # Start console
  begin
    require 'pry'
    pry
  rescue LoadError
    require 'irb'
    ARGV.clear
    IRB.start
  end
end
