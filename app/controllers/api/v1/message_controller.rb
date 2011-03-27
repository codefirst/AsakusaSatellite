module Api
  module V1
    class MessageController < ApplicationController
      include ChatHelper
      include ApiHelper
      include Rails.application.routes.url_helpers

      before_filter :check_spell, :except => [ :list, :show ]
      respond_to :json

      def list
        count = if params[:count] then
                  params[:count].to_i
                else
                  20
                end
        case
        when params[:until_id]
          message = Message.find params[:until_id]
          @messages = message.prev(count-1)
          @messages << message
        when params[:since_id]
          message = Message.find params[:since_id]
          @messages = message.next(count)
        else
          room = Room.find(params[:room_id])
          @messages = room.messages(count)
        end
        respond_with(@messages.map{|m| to_json(m) })
      end

      def show
        @message = Message.find params[:id]
        if @message then
          respond_with(to_json(@message))
        else
          render :json => {:status => 'error', :error => "message #{params[:id]} is not exists"}
        end
      end

      def create
        create_message(params[:room_id], params[:message])
        room = Room.find(params[:room_id])
        room.updated_at = Time.now
        room.save

        render :json => {:status => 'ok'}
      end

      def update
        message = Message.find(params[:id])
        unless message and message.user and current_user and message.user.screen_name == current_user.screen_name
          render :json => {:status => 'error', :error => "message #{params[:id]} is not your own"}
          return
        end
        update_message(params[:id], params[:message])
        render :json => {:status => 'ok'}
      end

      def destroy
        message = Message.find(params[:id])
        unless message and message.user and current_user and message.user.screen_name == current_user.screen_name
          render :json => {:status => 'error', :error => "message #{params[:id]} is not your own"}
          return
        end
        delete_message(params[:id])
        render :json => {:status => 'ok'}
      end
    end
  end
end
