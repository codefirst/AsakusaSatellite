#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'em-websocket'
require 'json'

require 'asakusa_satellite/url_util'

class ClientSide
  def initialize(routes, logger, port=8080)
    @routes = routes
    @logger = logger
    @clients = {}
    @port = port
  end

  def parse(path)

  end

  def run
    @logger.info "Websocket server start"
    EventMachine::WebSocket.start(:host => '0.0.0.0',
                                  :port => @port) do |ws|
      ws.onopen do
        @logger.info "on open: #{ws.request.inspect}"
        dispatch(ws.request['Path'])do|event|
          @clients[ws] = event.listen do|hash|
            @logger.info "send #{hash.inspect}"
            ws.send hash.to_json
          end
        end
      end

      ws.onclose do
        @logger.info "on close: #{ws.request.inspect}"
        dispatch(ws.request['Path'])do|event, query|
          event.remove @clients[ws]
        end
        @clients.delete ws
      end
    end
  end

  private
  def dispatch(path, &f)
    result = AsakusaSatellite::UrlUtil.parse path
    begin
      f[@routes.send(result[:name], result[:query])]
    rescue => e
      @logger.error "unknown #{path}: #{e.inspect}"
    end
  end
end


