# Load the rails application
require File.expand_path('../application', __FILE__)
require 'yaml'
require 'ostruct'
require 'asakusa_satellite/filter'

config = lambda do|name|
  YAML.load_file File.expand_path("../#{name}.yml", __FILE__)
end

WebsocketConfig = OpenStruct.new config['websocket']
AsakusaSatellite::Filter.initialize! config['filter']

# Initialize the rails application
AsakusaSatellite::Application.initialize!
