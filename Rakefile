# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

include Rake::DSL
AsakusaSatellite::Application.load_tasks

if %(development test).include?(Rails.env)
  require 'rspec/core'
  require 'rspec/core/rake_task'

  namespace :spec do
    RSpec::Core::RakeTask.new(:all) do |t|
      t.pattern = ["./spec/**/*_spec.rb", "./plugins/as_*/spec/**/*_spec.rb"]
    end
    RSpec::Core::RakeTask.new(:plugins) do |t|
      t.pattern = ["./plugins/as_*/spec/**/*_spec.rb"]
    end
  end

  if default = Rake.application.instance_variable_get('@tasks')['default']
    default.prerequisites.delete('spec')
  end
  task :default => :'spec:all'
end

