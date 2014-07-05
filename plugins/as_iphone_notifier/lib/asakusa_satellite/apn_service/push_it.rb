# -*- encoding: utf-8 -*-

module AsakusaSatellite
  module APNService
    class PushIt < Base

      def send_message(device_tokens, room, text)
        body = json(device_tokens, room, text).to_json
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

      def json(device_tokens, room, text)
        {
          :tokens => device_tokens,
          :payload => {
            :aps => {
              :alert => text,
              :sound => "default"
            },
            :id => room.id.to_s
          }
        }
      end

    end if ENV['PUSH_IT_URL']
  end
end
