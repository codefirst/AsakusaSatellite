# -*- mode:ruby; coding:utf-8 -*-
require "rubygems"
require "bundler/setup"
require 'em-websocket'
require 'sinatra'
require 'thin'
require 'uri'
require 'open-uri'
require 'yaml'

config_path = File.expand_path('../config/websocket.yml',
                               File.dirname(__FILE__))
puts "load from: #{config_path}"
WsConfig = YAML.load_file config_path
p WsConfig

def rails_root
  "http#{WsConfig['use_rails_ssl'] ? 's' : ''}://#{WsConfig['roots']}"
end

EventMachine.run do
  $clients = []

  EventMachine::WebSocket.start(:host => '0.0.0.0',
                                :port => WsConfig['websocketPort']) do |ws|
    ws.onopen do
      $clients << ws
    end

    ws.onmessage do |msg|
      puts "recv: #{msg}"
      open(URI.encode("#{rails_root}/tweets/new?content=#{msg}")){|_|}
    end

    ws.onclose do
      $clients.delete ws
    end
  end

  class App < Sinatra::Base
    get '/message/:event/:id' do
      event = params[:event]
      id    = params[:id]
      case event
      when 'create', 'update'
        open("#{rails_root}/api/v1/message/#{id}.json"){|io|
          json = <<JSON
          {
            "event" : "#{event}",
            "content" : #{io.read}
          }
JSON
          $clients.each{|ws|
            ws.send json }
        }
      end
      "ok"
    end
  end
  App.run! :port => WsConfig['httpPort']
end
