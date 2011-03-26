#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'msgpack-rpc'

class RailsSide
  def initialize(routes, logger, port)
    @routes = routes
    @logger = logger
    @port   = port
  end

  def message_create(room, content)
    @logger.info [room, content].inspect
    @routes.message_create.fire room, content
  end

  def message_update(room, content)
    @logger.info [room, content].inspect
    @routes.message_update.fire room, content
  end

  def message_delete(room, id)
    @logger.info [room, id].inspect
    @routes.message_delete.fire room, { 'id' => id }
  end

  def run
    @logger.info "MessagePack server start"
    server = MessagePack::RPC::Server.new
    server.listen('127.0.0.1', @port, self)
    server.run
  end
end
