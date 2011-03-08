module Api
  module V1
    class MessageController < ApplicationController
      include ChatHelper
      include Rails.application.routes.url_helpers

      before_filter :check_spell, :only => [:create, :update, :destroy]
      respond_to :json

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
