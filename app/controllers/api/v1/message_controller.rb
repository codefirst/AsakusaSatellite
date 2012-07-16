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
        return unless accessible?(room)
        count = params[:count] ? params[:count].to_i : 20
        if params[:until_id] or params[:since_id]
          @messages = room.messages_between(params[:since_id], params[:until_id], count) 
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
          render :json => {:status => 'error', :error => "message #{params[:id]} does not exists"}
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

      private
      def accessible?(room)
        if room.nil?
          render :json => {:status => 'error', :error => "room #{room_id} does not exists"}
          return false
        end
        unless room.is_public
          return false unless check_spell
        end
        unless room.accessible?(current_user)
          render :json => {:status => 'error', :error => "room #{room_id} does not exists"}
          return false
        end
        true
      end
    end
  end
end
