# -*- mode:ruby; coding:utf-8 -*-
require "rubygems"
require "bundler/setup"
require 'em-websocket'
require 'sinatra'
require 'thin'
require 'active_groonga'
require 'uri'
require 'open-uri'

rails_env = ENV['RAILS_ENV'] || 'development'
Groonga::Context.default_options = { :encoding => :utf8 }
Groonga::Database.new File.expand_path("../db/groonga/#{rails_env}/db",File.dirname(__FILE__))

Dir[File.expand_path('../app/models/*',File.dirname(__FILE__))].each do|model|
  puts model
  load model
end


EventMachine.run do
  $clients = []

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8080) do |ws|
    ws.onopen do
      $clients << ws
    end

    ws.onmessage do |msg|
      puts "recv: #{msg}"
      open(URI.encode("http://0.0.0.0:3000/tweets/new?content=#{msg}")){|_|}
    end

    ws.onclose do
      $clients.delete ws
    end
  end

  class App < Sinatra::Base
    get '/message/:event/:id' do
      event = params[:event]
      id    = params[:id]
      puts "#{event}: #{id}"
      case event
      when 'create', 'update'
        m = Message.find(id)
        json = <<JSON
{
  "event" : "#{event}",
  "content" : #{m.encode_json(nil)}
}
JSON
        puts json
        $clients.each{|c|
          c.send json
        }
      end
      ""
    end
  end
  App.run! :port => 8081
end
