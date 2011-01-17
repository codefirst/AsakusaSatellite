# -*- mode:ruby; coding:utf-8 -*-
require "rubygems"
require "bundler/setup"
require 'em-websocket'
require 'sinatra'
require 'thin'
require 'active_groonga'
require 'uri'
require 'open-uri'

Groonga::Context.default_options = { :encoding => :utf8 }
Groonga::Database.new File.expand_path('../db/groonga/development/db',File.dirname(__FILE__))

require File.expand_path('../app/models/message',File.dirname(__FILE__))

EventMachine.run do
  $clients = []

  class App < Sinatra::Base
    get '/publish' do
      t = Time.now.to_s
      $clients.each {|c| c.send t.to_s }
      'ok'
    end
  end

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

  App.run! :port => 8081
end
