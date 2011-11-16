module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper
      include ApiHelper

      before_filter :check_spell

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
        room = Room.get(params[:id], @current_user)
        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
        elsif room.update_attributes(:title => params[:name])
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room creation failure"}
        end
      end

      def destroy
        room = Room.get(params[:id], @current_user)
        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
        elsif room.update_attributes(:deleted => true)
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room deletion failure"}
        end
      end

      def list
        render :json => Room.all_live(current_user).map {|r| r.to_json }
      end

      def add_member
        room = Room.get(params[:id], @current_user)
        user = User.find(params[:user_id])

        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
        elsif user.nil?
          render :json => {:status => 'error', :error => "user not found"}
        else
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
end
