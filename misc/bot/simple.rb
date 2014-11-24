#!/user/bin/env ruby
# -*- mode:ruby; coding:utf-8 -*-

# ------------------------------
# example for bot
# ------------------------------

# Get from http://$AS_ROOT/account/index
API_KEY = "YOUR_API_KEY"

# EntryPoint
ENTRY_POINT = "http://localhost:3000/api/v1"

# ------------------------------
require 'net/https'

if ARGV.size != 2 then
  puts "#{$0} <room_id> <message>"
  exit 0
end

room_id, message = *ARGV
uri = URI(ENTRY_POINT)

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = uri.scheme == 'https'
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.start do |h|
  # post message
  p h.post(uri.path + "/message", URI.encode_www_form({
               room_id: room_id,
               api_key: API_KEY,
               message: message
             }))
end

