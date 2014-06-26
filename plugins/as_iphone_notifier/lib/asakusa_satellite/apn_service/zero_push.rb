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
        ::ZeroPush.register(normalize(device.name))
      end

      def unregister(device)
        ::ZeroPush.unregister(normalize(device.name))
      end

      def send_message(device_tokens, room, text)
        ::ZeroPush.notify({
          :device_tokens => device_tokens.map(&method(:normalize)),
          :alert => text,
          :sound => "default",
          :info  => { :id => room.id }
        })
      end

      private
      def normalize(token)
        token.gsub(/[\s|<|>]/, '')
      end
    end if ENV['ZEROPUSH_TOKEN']
  end
end
