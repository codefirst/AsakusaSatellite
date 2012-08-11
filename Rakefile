# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

include Rake::DSL
AsakusaSatellite::Application.load_tasks

if %(development test).include?(Rails.env)
  require 'rspec/core'
  require 'rspec/core/rake_task'
  require 'ci/reporter/rake/rspec'

  namespace :plugins do
    RSpec::Core::RakeTask.new(:spec) do|t|
      t.pattern = "./vendor/plugins/as_*/spec/**/*_spec.rb"
    end
  end
end

