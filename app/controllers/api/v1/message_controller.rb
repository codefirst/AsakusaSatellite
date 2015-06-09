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
        room_id    = params[:room_id]
        since_id   = params[:since_id]
        newer_than = params[:newer_than]
        until_id   = params[:until_id]
        older_than = params[:older_than]

        if (since_id and newer_than) or (until_id and older_than)
          render_error("duplicated parameters are specified", 403) and return
        end

        Room.with_room(room_id, current_user) do |room|
          render_error("room does not exist", 403) and return unless room

          count = params[:count] ? params[:count].to_i : 20
          order = case params[:order]
                  when 'asc'  then :asc
                  when 'desc' then :desc
                  else             nil
                  end
          from_id = since_id || newer_than
          to_id   = until_id || older_than
          from    = {:id => from_id, :include_boundary => (not since_id.blank?)} if from_id
          to      = {:id => to_id,   :include_boundary => (not until_id.blank?)} if to_id

          if from or to
            messages = room.messages_between(from, to, count, order)
          else
            messages = room.messages(count, order)
          end

          respond_with(messages.map{|m| cache([m, :api]){to_json(m)}})
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

          files = (params["files"] || {}).values
          has_files = !(files.empty?)

          case message = Message.make(current_user, room, params[:message], has_files)
          when Message
            files.each {|file| message.attach(file)}
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

      def search
        room_id = params[:room_id]
        query   = params[:query]

        messages = {}
        Room.with_room(room_id, current_user) do |room|
          return render_error("room does not exist", 403) unless room

          messages = Message.find_by_text(:text => query, :rooms => [ room ], :limit => 20)
        end unless query.blank?
        render :json => messages.map { |m| { :room => m[:room], :messages => m[:messages].map(&:to_hash) } }
      end
    end
  end
end
