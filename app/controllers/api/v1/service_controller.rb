# -*- encoding: utf-8 -*-
module Api
  module V1
    class ServiceController < ApplicationController
      include ApiHelper
      respond_to :json
      before_filter :check_spell

      def info
        respond_with( {
          :message_pusher => {
          :name => AsakusaSatellite::MessagePusher.name,
          :param => AsakusaSatellite::MessagePusher.param
        }
        } )
      end
    end
  end
end
