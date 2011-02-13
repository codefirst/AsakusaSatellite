module Api
  module V1
    class MessageController < ApplicationController
      include ChatHelper
      respond_to :json

      def show
        @message = Message.find params[:id]
        respond_with(to_json(@message))
      end

      def create
        unless logged?
          render :json => {:status => 'error', :error => 'login not yet'}
          return
        end
        create_message(params[:room_id], params[:message])
        room = Room.find(params[:room_id])
        room.updated_at = Time.now
        room.save

        render :json => {:status => 'ok'}
      end

      def update
        unless logged?
          render :json => {:status => 'error', :error => 'login not yet'}
          return
        end
        update_message(params[:id], params[:message])
        render :json => {:status => 'ok'}
      end

      def destroy
        unless logged?
          render :json => {:status => 'error', :error => 'login not yet'}
          return
        end
        delete_message(params[:id])
        render :json => {:status => 'ok'}
      end
    end
  end
end
