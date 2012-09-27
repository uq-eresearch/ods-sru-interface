require 'bundler/setup'
require 'clockwork'
require 'delayed_job_active_record'

Dir.mkdir('tmp/data') rescue nil

module Clockwork

  every(6.hours, 'output.records') do
    models = [StaffPerson, Grant, GrantInvestigator, OrgUnit]
    IdZebra::log_level = :info
    IdZebra::API('config/zebra/zebra.cfg') do |repo|
      models.each do |model|
        # While slower than generating a single document, the
        # memory requirements are much less troublesome for a small VM.
        model.all.each do |obj|
          repo.add_record(obj.to_rif)
        end
        repo.commit
      end
      repo.compact
    end
  end

end
