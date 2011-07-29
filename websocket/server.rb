# -*- mode:ruby; coding:utf-8 -*-
require "rubygems"
require "bundler/setup"
require 'logger'

$: << File.dirname(__FILE__) + '/../lib'
$: << File.dirname(__FILE__)

require 'asakusa_satellite/routes'


require 'client_side'
require 'rails_side'

class MyRoutes < AsakusaSatellite::Routes
  source :message_create, :message_update, :message_delete
  map :room do|params|
    message_create.merge(:create,
                         :update => message_update,
                         :delete => message_delete).filter{|_,room,content|
      params[:id] == room
    }.map{|event, _, content|
      { 'event' => event.to_s, 'content' => content }
    }
  end
end

logger = Logger.new(STDOUT)
routes = MyRoutes.new

config_path = File.expand_path('../config/websocket.yml',
                               File.dirname(__FILE__))
logger.info "load from: #{config_path}"
WsConfig = YAML.load_file config_path


Thread.start do
  begin
    RailsSide.new( routes, logger, WsConfig['msgpackPort']).run
  rescue => e
    puts e
  end
end
ClientSide.new(routes, logger, WsConfig['websocketPort']).run
