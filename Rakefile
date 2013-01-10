#!/usr/bin/env rake

Bundler.setup

# Include rake task files
rake_task_files = File.join(File.dirname(__FILE__), 'lib', 'tasks', '*.rake')
Dir.glob(rake_task_files).sort.each {|f| import f}

task :default => :spec
