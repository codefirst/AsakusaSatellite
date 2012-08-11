# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'ci/reporter/rake/rspec'
require 'rspec/core/rake_task'

include Rake::DSL
AsakusaSatellite::Application.load_tasks

namespace :plugins do
  RSpec::Core::RakeTask.new(:spec) do|t|
    t.pattern = "./vendor/plugins/as_*/spec/**/*_spec.rb"
  end
end
