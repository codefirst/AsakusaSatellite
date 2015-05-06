# -*- encoding: utf-8 -*-
module AsakusaSatellite
  module APNService
    class Base
      PAYLOAD_SIZE_LIMIT = 150

      class << self
        def inherited(child)
          apns_classes << child
        end

        def find_class
          apns_classes.last
        end

        def apns_classes
          @apns_classes ||= [Base]
        end

      end

      def register(device); end
      def unregister(device); end
      def send_message(device_tokens, room, message); end

      def alert(message)
        not_attached = message.attachments.empty?
        body = not_attached ? message.body : message.attachments[0].filename
        strip("#{message.user.name} / #{body}", PAYLOAD_SIZE_LIMIT)
      end

      private
      def strip(str, n)
        escaped = str.to_json.match(/^"(.*)"$/)[1]
        len = 0
        s = escaped.scan(/((\\u[0-9a-f]{4})|(.))/).map(&:first).take_while{|escaped_char|
          len += escaped_char.length
          len <= n
        }.join
        (JSON.parse "[\"#{s}\"]")[0]
      end
    end

    def self.instance
      @@instance ||= Base.find_class.new
    end
  end
end
