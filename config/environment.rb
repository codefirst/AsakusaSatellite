# Load the rails application
require File.expand_path('../application', __FILE__)
require 'yaml'
require 'ostruct'
require 'asakusa_satellite'

config = lambda do|name|
  YAML::load(ERB.new(File.read(File.expand_path("../#{name}.yml", __FILE__))).result)
end

filter = ENV['FILTER_NAME'] || 'filter_intra'
filter_config = AsakusaSatellite::Filter::FilterConfig.initialize! config[filter]
AsakusaSatellite::Filter.initialize! filter_config
AsakusaSatellite::Hook.initialize! filter_config
AsakusaSatellite::MessagePusher.engines = config['message_pusher']['engines']
AsakusaSatellite::MessagePusher.default = config['message_pusher']['default']

# Initialize the rails application
Rails.application.initialize!
