#! /opt/local/bin/ruby -w
# -*- mode:ruby; encoding:utf-8 -*-
require 'base64'

#APNS.host = 'gateway.push.apple.com'
PEM_FILE = File.dirname(__FILE__) + '/../../../../../tmp/apns-sandbox-cert.pem'

pem = ENV['PEM']

if pem
   content = Base64.decode64(pem.gsub('\n', "\n"))
else
   warn "Set ENV['PEM'] for Notification"
   content = ''
end

open(PEM_FILE, 'w') do |f|
   f.write(content)
end

APNS.pem = PEM_FILE
APNS.port = 2195

