module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper
      respond_to :json, :xml
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

      def post
        unless User.logged?
          render :json => {:status => 'error', :error => 'login not yet'}
          return
        end
        create_message(params[:room_id], params[:message])
        render :json => {:status => 'ok'}
      end
    end
  end
end
