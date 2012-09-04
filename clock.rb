require 'bundler/setup'
require 'clockwork'
require 'delayed_job_active_record'

Dir.mkdir('tmp/data') rescue nil

module Clockwork

  every(5.minutes, 'output.records') do
    models = [Grant, OrgUnit, StaffPerson]
    models.each do |model|
      model_name = model.name.underscore.dasherize
      model.all.each do |grant|
        File.open('tmp/data/%s-%s.xml' % [model_name, grant.id], 'wb') do |f|
          f.write(grant.to_rif)
        end
      end
    end
    system('zebraidx -c config/zebra/zebra.cfg update tmp/data')
    system('zebraidx -c config/zebra/zebra.cfg commit')
  end

end
