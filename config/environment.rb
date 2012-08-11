# Load the rails application
require File.expand_path('../application', __FILE__)
require 'yaml'
require 'ostruct'
require 'asakusa_satellite/filter'
require 'asakusa_satellite/hook'
require 'asakusa_satellite/message_pusher'

config = lambda do|name|
  YAML::load(ERB.new(File.read(File.expand_path("../#{name}.yml", __FILE__))).result)
end

AsakusaSatellite::Filter.initialize! config['filter']
AsakusaSatellite::Hook.initialize! config['filter']
AsakusaSatellite::MessagePusher.engines = config['message_pusher']['engines']
AsakusaSatellite::MessagePusher.default = config['message_pusher']['default']

# Initialize the rails application
AsakusaSatellite::Application.initialize!
