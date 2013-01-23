Bundler.setup
require 'clockwork'
require 'active_record'

# To handle use of cattr_accessor in oracle_enhanced_adapter
require 'active_support/all'

require 'active_record/connection_adapters/oracle_enhanced_adapter'
require 'idzebra'

# Include models
Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each {|f| require f}

Dir.mkdir('tmp/data') rescue nil

# Set home correctly, as Zebra config needs it
require 'etc'
ENV['HOME'] = Etc.getpwuid.dir

module Clockwork

  def update_sru_records(model, use_bulk = false)
    IdZebra::log_level = :info
    IdZebra::API('config/zebra/zebra.cfg') do |repo|
      repo.transaction do
        if use_bulk and model.respond_to?(:to_rif)
          puts "Building RIF-CS data for #{model}"
          data = model.to_rif
          puts "Adding data to repository for #{model}"
          repo.add_record(data)
        else
          # While much slower than generating a single document, the
          # memory requirements can be less troublesome for a small VM.
          model.all.each do |obj|
            repo.add_record(obj.to_rif)
          end
        end
      end
      repo.commit
      repo.compact
    end
  end

  every(6.hours, 'output.records') do
    [OrgUnit, Grant, StaffPerson].each {|m| update_sru_records(m, true)}
  end

end
