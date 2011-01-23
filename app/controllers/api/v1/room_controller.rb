module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper
      respond_to :json
      def show
        room = Room.find(params[:id])
        if params[:since_date]
          @messages = Message.select do |record|
            [
              record.created_at >= params[:since_date].to_date.beginning_of_day.to_i,
              record.room == room
            ]
          end
        else
          @messages = Message.all
        end
        respond_with(@messages)
      end

    end
  end
end
