# -*- encoding: utf-8 -*-
module AsakusaSatellite
  module APNService
    class Base
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
      def send_message(device_tokens, room, text); end
    end

    def self.instance
      @@instance ||= Base.find_class.new
    end
  end
end
