# -*- encoding: utf-8 -*-
module Api
  module V1
    class MessageController < ApplicationController
      include ChatHelper
      include ApiHelper
      include RoomHelper
      include Rails.application.routes.url_helpers

      before_filter :check_spell
      respond_to :json

      def list
        room_id = params[:room_id]
        with_room(room_id, :not_auth => (not logged?)) do|room|
          if room.nil?
            render :json => {:status => 'error', :error => "room does not exist"}
          else
            count = params[:count] ? params[:count].to_i : 20
            if params[:until_id] or params[:since_id]
              @messages = room.messages_between(params[:since_id], params[:until_id], count)
            else
              @messages = room.messages(count)
            end
            respond_with(@messages.map{|m| to_json(m) })
          end
        end
      end

      def show
        begin
          @message = Message.find(params[:id])
        rescue
          render :json => {:status => 'error', :error => "message #{params[:id]} not found"}
          return
        end
        room = @message.room
        if accessible?(@message)
          respond_with(to_json(@message))
        else
          render :json => {:status => 'error', :error => "message #{params[:id]} not found"}
        end
      end

      def create
        unless logged?
          render_login_error
          return
        end
        with_room(params[:room_id]) do|room|
          message = create_message(room, params[:message])
          unless message
            render :json => {:status => 'error', :error => "message creation failed"}
            return
          end
          room.updated_at = Time.now
          room.save
          render :json => {:status => 'ok', :message_id => message.id}
        end
      end

      def update
        unless logged?
          render_login_error
          return
        end
        message = Message.find(params[:id])
        unless message and message.user and current_user and message.user.screen_name == current_user.screen_name
          render :json => {:status => 'error', :error => "message #{params[:id]} is not your own"}
          return
        end
        update_message(params[:id], params[:message])
        render :json => {:status => 'ok'}
      end

      def destroy
        unless logged?
          render_login_error
          return
        end
        message = Message.where(:_id => params[:id]).first
        unless message and message.user and current_user and message.user.screen_name == current_user.screen_name
          render :json => {:status => 'error', :error => "message #{params[:id]} is not your own"}
          return
        end
        delete_message(params[:id])
        render :json => {:status => 'ok'}
      end

      private
      def accessible?(message)
        room = message.room
        if room.nil?
          return false
        end
        unless room.is_public
          return false unless logged?
        end
        unless room.accessible?(current_user)
          return false
        end
        true
      end
    end
  end
end
