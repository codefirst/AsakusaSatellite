module Api
  module V1
    class MessageController < ApplicationController
      include ChatHelper
      include ApiHelper
      include Rails.application.routes.url_helpers

      before_filter :check_spell, :except => [ :list, :show ]
      respond_to :json

      def list
        room_id = params[:room_id]
        room = Room.where(:_id => room_id).first
        unless room.is_public
          return unless check_spell
        end
        if room.nil? or (not room.accessible?(current_user))
          render :json => {:status => 'error', :error => "room #{room_id} is not exists"}
          return
        end
        count = params[:count] ? params[:count].to_i : 20
        case
        when (params[:until_id] and params[:since_id])
          @messages = Message.between(room_id, params[:since_id], params[:until_id], count)
        when params[:until_id]
          message = Message.where(:room_id => room_id).where(:_id => params[:until_id]).first
          @messages = message.prev(count-1)
          @messages << message
        when params[:since_id]
          message = Message.where(:room_id => room_id).where(:_id => params[:since_id]).first
          @messages = message.next(count)
        else
          @messages = room.messages(count)
        end
        respond_with(@messages.map{|m| to_json(m) })
      end

      def show
        @message = Message.find params[:id]
        if @message and @message.room.accessible?(current_user) then
          respond_with(to_json(@message))
        else
          render :json => {:status => 'error', :error => "message #{params[:id]} is not exists"}
        end
      end

      def create
        room = Room.find(params[:room_id])
        create_message(room, params[:message])
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
        message = Message.where(:_id => params[:id]).first
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
