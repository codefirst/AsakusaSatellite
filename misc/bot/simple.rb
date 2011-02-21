#! /user/bin/env ruby
# -*- mode:ruby; coding:utf-8 -*-

# ------------------------------
# example for bot
# ------------------------------

# Twitter's screen name
ScreenName = "AsaxaSatellite"

# Get from http://$AS_ROOT/account/index
Password   = "AsGklaaVMtMiVxx69OEsZfcma"

# EntryPoint
EntryPoint = "http://localhost:3000/api/v1"

# ------------------------------
require 'net/http'

if ARGV.size != 2 then
  puts "#{$0} <room_id> <message>"
  exit 0
end

room_id, message = *ARGV
uri = URI(EntryPoint)

Net::HTTP.start(uri.host, uri.port) do| http |
  # login
  session = http.get(uri.path + "/login?user=#{ScreenName}&password=#{Password}")
  cookie  = session['set-cookie'].split(";",2).first

  # post message
  p http.post(uri.path + "/message",
              "room_id=#{room_id}&message=#{message}",
              "Cookie" => cookie)
end
