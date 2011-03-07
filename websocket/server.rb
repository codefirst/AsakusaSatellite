# -*- mode:ruby; coding:utf-8 -*-
require "rubygems"
require "bundler/setup"
require 'em-websocket'
require 'sinatra'
require 'thin'
require 'uri'
require 'open-uri'
require 'yaml'
require 'logger'

$log = Logger.new(STDOUT)

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

config_path = File.expand_path('../config/websocket.yml',
                               File.dirname(__FILE__))
puts "load from: #{config_path}"
WsConfig = YAML.load_file config_path
$log.info WsConfig.inspect

def rails_root
  "http#{WsConfig['use_rails_ssl'] ? 's' : ''}://#{WsConfig['roots']}"
end

EventMachine.run do
  $clients = Hash.new {|hash, key|
    hash[key] = []
  }

  EventMachine::WebSocket.start(:host => 'localhost',
                                :port => WsConfig['websocketPort']) do |ws|
    ws.onopen do
      $log.info "on open: #{ws.request['Query'].inspect}"
      room =  ws.request['Query']['room']
      $clients[room] << ws
    end

    ws.onclose do
      $log.info "on close: #{ws.request['Query'].inspect}"
      room =  ws.request['Query']['room']
      $clients[room].delete ws
    end
  end

  class App < Sinatra::Base
    get '/message/:event/:id' do
      event = params[:event]
      id    = params[:id]
      room  = params[:room]
      case event
      when 'create', 'update'
        open("#{rails_root}/api/v1/message/#{id}.json"){|io|
          json = <<JSON
          {
            "event" : "#{event}",
            "content" : #{io.read}
          }
JSON
          $clients[room].each do|ws|
            begin
              ws.send json
            rescue => e
              $log.error e.inspect
            end
          end
        }
      when 'delete'
        json = <<JSON
          {
            "event" : "#{event}",
            "content" : { id : #{id} }
          }
JSON

        puts json
        $clients[room].each do|ws|
          begin
            ws.send json
          rescue => e
            $log.error e.inspect
          end
        end
      end
      "ok"
    end
  end
  App.run! :port => WsConfig['httpPort']
end
