# -*- encoding: utf-8 -*-

module AsakusaSatellite
  module APNService
    class ZeroPush < Base
      ZEROPUSH_TOKEN = ENV['ZEROPUSH_TOKEN']

      def initialize
        ::ZeroPush.auth_token = ZEROPUSH_TOKEN
        ::ZeroPush.verify_credentials
      end

      def register(device)
        ::ZeroPush.register(normalize(device.name)) if device.ios?
      end

      def unregister(device)
        ::ZeroPush.unregister(normalize(device.name)) if device.ios?
      end

      def send_message(device_tokens, room, message)
        ::ZeroPush.notify({
          :device_tokens => device_tokens.map(&method(:normalize)),
          :alert => alert(message),
          :sound => "default",
          :category => NOTIFICATION_CATEGORY,
          :info  => {
            :room_id => room.id.to_s,
            :user => message.user.screen_name
          }
        })
      end

      private
      def normalize(token)
        token.gsub(/[\s|<|>]/, '')
      end
    end if ENV['ZEROPUSH_TOKEN'] and defined?(::ZeroPush)
  end
end
