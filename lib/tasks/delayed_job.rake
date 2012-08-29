require 'delayed/tasks'

task :sync_output do
  STDERR.sync = STDOUT.sync = true
end

# Enhance existing worker job
Rake::Task['jobs:work'].enhance([:sync_output])

