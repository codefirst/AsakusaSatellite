module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper
      include ApiHelper

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
        render :json => Room.where(:deleted => false).map {|r| r.to_json }
      end

      def add_member
        room = Room.find(params[:id])
        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
        end
        user = User.find(params[:user_id])
        if user.nil?
          render :json => {:status => 'error', :error => "user not found"}
        end
        room.members ||= []
        room.members << user
        if room.save
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "add user"}
        end
      end
    end
  end
end
