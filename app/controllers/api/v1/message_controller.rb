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
        Message.with_message(params[:id]) do |message|
          render_message_not_found(params[:id]) and return unless message

          if message.accessible?(current_user)
            respond_with(to_json(message))
          else
            render_message_not_found(params[:id]) and return
          end
        end
      end

      def create
        render_login_error and return unless logged?

        with_room(params[:room_id]) do |room|
          render_room_not_found(params[:room_id]) and return unless room

          message = Message.create_message(room, current_user, params[:message])
          render_message_creation_error and return unless message

          publish_message(:create, message, room)
          room.update_attributes(:updated_at => Time.now)

          render :json => {:status => 'ok', :message_id => message.id}
        end
      end

      def update
        render_login_error and return unless logged?

        Message.with_own_message(params[:id], current_user) do |message|
          render_message_not_found(params[:id]) and return unless message

          update_message(params[:id], params[:message])
          render :json => {:status => 'ok'}
        end
      end

      def destroy
        render_login_error and return unless logged?

        Message.with_own_message(params[:id], current_user) do |message|
          render_message_not_found(params[:id]) and return unless message

          delete_message(params[:id])
          render :json => {:status => 'ok'}
        end
      end
    end
  end
end
