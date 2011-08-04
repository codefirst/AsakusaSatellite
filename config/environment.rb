# Load the rails application
require File.expand_path('../application', __FILE__)
require 'yaml'
require 'ostruct'
require 'asakusa_satellite/filter'
require 'asakusa_satellite/hook'

config = lambda do|name|
  YAML.load_file File.expand_path("../#{name}.yml", __FILE__)
end

AsakusaSatellite::Filter.initialize! config['filter']
AsakusaSatellite::Hook.initialize! config['filter']

# Initialize the rails application
AsakusaSatellite::Application.initialize!
