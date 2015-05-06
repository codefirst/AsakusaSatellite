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

        File.write(PEM_FILE, content)

        APNS.pem = PEM_FILE
        APNS.port = 2195
      end

      def send_message(device_tokens, room, message)
        device_tokens.map { |device_token|
          APNS::Notification.new(device_token,
            :alert => alert(message),
            :sound => 'default',
            :category => NOTIFICATION_CATEGORY,
            :other => {
              :room_id => room.id.to_s,
              :user => message.user.screen_name
            }
          )
        }.tap { |notification|
          APNS.send_notifications notification
        }
      end
    end if ENV['PEM']
  end
end
