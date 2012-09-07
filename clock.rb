require 'bundler/setup'
require 'clockwork'
require 'delayed_job_active_record'

Dir.mkdir('tmp/data') rescue nil

module Clockwork

  every(5.minutes, 'output.records') do
    models = [Grant, OrgUnit, StaffPerson]
    IdZebra::log_level = :warn
    IdZebra::API('config/zebra/zebra.cfg') do |repo|
      models.each do |model|
        model.all.each do |obj|
          repo.add_record(obj.to_rif)
        end
      end
      repo.commit
    end
  end

end
