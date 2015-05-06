# -*- encoding: utf-8 -*-

module AsakusaSatellite
  module APNService
    class PushIt < Base

      def send_message(device_tokens, room, message)
        body = json(device_tokens, room, message).to_json
        begin
          client.start do |connection|
            connection.post("/message", body)
          end
        rescue Errno::ECONNREFUSED => e
          Rails.logger.error e
        end
      end

      private

      def client
        uri = URI.parse(ENV['PUSH_IT_URL'])
        client = Net::HTTP.new(uri.host, uri.port)
        client.use_ssl = uri.scheme == 'https'
        client
      end

      def json(device_tokens, room, message)
        {
          :tokens => device_tokens,
          :payload => {
            :aps => {
              :alert => alert(message),
              :sound => "default",
              :category => NOTIFICATION_CATEGORY
            },
            :room_id => room.id.to_s,
            :user => message.user.screen_name
          }
        }
      end

    end if ENV['PUSH_IT_URL']
  end
end
