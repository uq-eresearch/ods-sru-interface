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

module Clockwork

  def update_sru_records(model, use_bulk = false)
    IdZebra::log_level = :info
    IdZebra::API('config/zebra/zebra.cfg') do |repo|
      repo.transaction do
        if use_bulk and model.respond_to?(:to_rif)
          repo.add_record(model.to_rif)
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

  every(6.hours, 'output.orgunits') do
    [OrgUnit, StaffPerson, Grant].each {|m| update_sru_records(m, true)}
  end

end
