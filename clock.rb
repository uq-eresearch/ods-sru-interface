require 'bundler/setup'
require 'clockwork'

Dir.mkdir('tmp/data') rescue nil

module Clockwork

  def update_sru_records(model, use_bulk = false)
    IdZebra::log_level = :info
    IdZebra::API('config/zebra/zebra.cfg') do |repo|
      if use_bulk and model.respond_to?(:to_rif)
        repo.add_record(model.to_rif)
      else
        # While much slower than generating a single document, the
        # memory requirements can be less troublesome for a small VM.
        model.all.each do |obj|
          repo.add_record(obj.to_rif)
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
