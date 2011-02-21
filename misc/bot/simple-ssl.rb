#! /user/bin/env ruby
# -*- mode:ruby; coding:utf-8 -*-

# ------------------------------
# example for bot
# ------------------------------

# Twitter's screen name
ScreenName = "{screen name}"

# Get from http://$AS_ROOT/account/index
Password   = "{password}"

# EntryPoint
EntryPoint = "https://localhost:3000/api/v1"

# ------------------------------
require 'net/https'

if ARGV.size != 2 then
  puts "#{$0} <room_id> <message>"
  exit 0
end

room_id, message = *ARGV
uri = URI(EntryPoint)

https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE
https.start do| conn |
  # login
  session = conn.get(uri.path + "/login?user=#{ScreenName}&password=#{Password}")
  cookie  = session['set-cookie'].split(";",2).first

  # post message
  p conn.post(uri.path + "/message",
              "room_id=#{room_id}&message=#{message}",
              "Cookie" => cookie)
end
