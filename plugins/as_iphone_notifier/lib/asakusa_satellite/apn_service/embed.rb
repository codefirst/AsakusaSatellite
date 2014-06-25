# -*- encoding: utf-8 -*-
include APNS

module AsakusaSatellite
  module APNService
    class Embed < Base
      PEM_FILE = File.dirname(__FILE__) + '/../../../../../tmp/apns-sandbox-cert.pem'

      def initialize
        pem = ENV['PEM']

        if pem
          content = Base64.decode64(pem.gsub('\n', "\n"))
          content.force_encoding('utf-8') rescue content # TODO remove me
        else
          warn "Set ENV['PEM'] for Notification"
          content = ''
        end

        open(PEM_FILE, 'w') { |f| f.write(content) }

        APNS.pem = PEM_FILE
        APNS.port = 2195
      end

      def send(device_tokens, room, text)
        device_tokens.map { |device_token|
          APNS::Notification.new(device_token,
            :alert => text,
            :sound => 'default',
            :other => { :id => room.id }
          )
        }.tap { |notification|
          APNS.send_notifications notification
        }
      end
    end
  end
end
