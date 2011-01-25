# Load the rails application
require File.expand_path('../application', __FILE__)

require 'yaml'
require 'ostruct'
WebsocketConfig =
  OpenStruct.new(YAML.load_file(File.expand_path('../websocket.yml',
                                                 __FILE__)))

# Initialize the rails application
AsakusaSatellite::Application.initialize!
