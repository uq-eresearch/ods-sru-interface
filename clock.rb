require 'bundler/setup'
require 'clockwork'
require 'delayed_job_active_record'

Dir.mkdir('tmp/data') rescue nil

module Clockwork

  every(15.minutes, 'output.records') do
    models = [StaffPerson, Grant, GrantInvestigator, OrgUnit]
    IdZebra::log_level = :info
    IdZebra::API('config/zebra/zebra.cfg') do |repo|
      models.each do |model|
        if model.respond_to?(:to_rif)
          repo.add_record(model.to_rif)
        else
          model.all.each do |obj|
            repo.add_record(obj.to_rif)
          end
        end
        repo.commit
      end
      repo.compact
    end
  end

end
