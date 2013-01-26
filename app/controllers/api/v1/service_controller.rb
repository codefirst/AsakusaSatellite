# -*- encoding: utf-8 -*-
module Api
  module V1
    class ServiceController < ApplicationController
      respond_to :json

      def info
        respond_with( {
          :message_pusher => AsakusaSatellite::MessagePusher.to_json
        } )
      end
    end
  end
end
