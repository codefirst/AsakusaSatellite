# -*- encoding: utf-8 -*-
module Api
  module V1
    class ServiceController < ApplicationController
      def info
        render :json => ({
          :message_pusher => AsakusaSatellite::MessagePusher.to_json
        })
      end
    end
  end
end
