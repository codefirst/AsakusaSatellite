module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper
      before_filter :check_spell, :except => [:list]

      respond_to :json
      def create
        room = Room.new(:title => params[:name], :user => current_user, :updated_at => Time.now)
        if room.save
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room creation failure"}
        end
      end

      def update
        room = Room.find(params[:id])
        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
          return
        end
        if room.update_attributes(:title => params[:name])
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room creation failure"}
        end
      end

      def destroy
        room = Room.find(params[:id])
        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
        end
        if room.update_attributes(:deleted => true)
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room deletion failure"}
        end
      end

      def list
        rooms = Room.select do |record|
          record.deleted == false
        end.to_a
        render :json => rooms.map {|r| r.to_json }
      end

      private
      def check_spell
        if params[:api_key]
          users = User.select do |record|
            record.spell == params[:api_key]
          end
          if users and users.first
            session[:current_user_id] = users.first.id
          end
        end
        unless logged?
          render :json => {:status => 'error', :error => 'login not yet'}
        end
      end
    end
  end
end
