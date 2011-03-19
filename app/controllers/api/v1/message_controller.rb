module Api
  module V1
    class MessageController < ApplicationController
      include ChatHelper
      include Rails.application.routes.url_helpers

      before_filter :check_spell, :only => [:create, :update, :destroy ]
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
        if Setting[:host]
          default_url_options[:host] = Setting[:host]
        end
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
        message = Message.find(params[:id])
        unless message and message.user and current_user and message.user.name == current_user.name
          render :json => {:status => 'error', :error => "message #{params[:id]} is not your own"}
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
        message = Message.find(params[:id])
        unless message and message.user and current_user and message.user.name == current_user.name
          render :json => {:status => 'error', :error => "message #{params[:id]} is not your own"}
          return
        end
        delete_message(params[:id])
        render :json => {:status => 'ok'}
      end

      def check_spell
        if params[:api_key]
          users = User.select do |record|
            record.spell == params[:api_key]
          end
          if users and users.first
            session[:current_user_id] = users.first.id
          end
        end
      end
    end
  end
end
