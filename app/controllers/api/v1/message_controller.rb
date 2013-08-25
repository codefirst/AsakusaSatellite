# -*- encoding: utf-8 -*-
module Api
  module V1
    class MessageController < ApplicationController
      include ChatHelper
      include ApiHelper
      include Rails.application.routes.url_helpers

      before_filter :check_spell
      respond_to :json

      def list
        room_id = params[:room_id]
        order = if params[:order] == 'asc'
                  :asc
                elsif params[:order] == 'desc'
                  :desc
                else
                  nil
                end

        Room.with_room(room_id, current_user) do |room|
          if room.nil?
            render_error "room does not exist", 403
          else
            count = params[:count] ? params[:count].to_i : 20
            if params[:until_id] or params[:since_id]
              @messages = room.messages_between(params[:since_id], params[:until_id], count, order)
            else
              @messages = room.messages(count, order)
            end
            respond_with(@messages.map{|m| to_json(m) })
          end
        end
      end

      def show
        case message = Message.where(:_id => params[:id]).first
        when Message
          if message.accessible?(current_user)
            respond_with(to_json(message))
          else
            render_message_not_found(params[:id])
          end
        when nil then render_message_not_found(params[:id])
        end
      end

      def create
        Room.with_room(params[:room_id], current_user) do |room|
          render_room_not_found(params[:room_id]) and return unless room

          case message = Message.make(current_user, room, params[:message])
          when Message
            if params["files"]
              params["files"].each_value {|file| Message.attach(message, file)}
            end
            room.update_attributes(:updated_at => Time.now)
            publish_message(:create, message, room)
            render :json => {:status => 'ok', :message_id => message.id}
          when :login_error   then render_login_error
          when :empty_message then render_error "empty message"
          when :error_on_save then render_message_creation_error
          end
        end
      end

      def update
        case message = Message.update_body(current_user, params[:id], params[:message])
        when Message
          publish_message(:update, message, message.room)
          render :json => {:status => 'ok'}
        when :login_error             then render_login_error
        when :error_message_not_found then render_message_not_found(params[:id])
        when :error_on_save           then render_error "save failed"
        end
      end

      def destroy
        case message = Message.delete(current_user, params[:id])
        when Message
          publish_message(:delete, message, message.room)
          render :json => {:status => 'ok'}
        when :login_error             then render_login_error
        when :error_message_not_found then render_message_not_found(params[:id])
        when :error_on_destroy        then render_error "destroy error"
        end
      end
    end
  end
end
