module Api
  module V1
    class RoomController < ApplicationController
      respond_to :json, :xml
      def show
        room = Room.find(params[:id])
        if params[:since_date]
          @messages = Message.select do |record|
            record.match("created_at:>=#{params[:since_date].to_date.beginning_of_day.to_i} room:#{params[:id]}")
          end
        else
          @messages = Message.all
        end
        logger.info "i++++++++++++++++++++++++++++++"
        logger.info @messages.expression[0]
        respond_with(@messages)
      end

    end
  end
end
