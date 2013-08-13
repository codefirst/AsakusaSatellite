# -*- encoding: utf-8 -*-
module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper
      include ApiHelper

      before_filter :check_spell

      respond_to :json
      def create
        render_login_error and return unless logged?

        case room = Room.make(params[:name], current_user)
        when Room           then render :json => {:status => 'ok', :room_id => room._id}
        when :login_error   then render_login_error
        when :error_on_save then render_error_on_save
        end
      end

      def update
        case Room.configure(params[:id], current_user, :title => params[:name])
        when Room                  then render :json => {:status => 'ok'}
        when :login_error          then render_login_error
        when :error_room_not_found then render_room_not_found(params[:id])
        when :error_on_save        then render_error_on_save
        end
      end

      def destroy
        case Room.delete(params[:id], current_user)
        when Room                  then render :json => {:status => 'ok'}
        when :login_error          then render_login_error
        when :error_room_not_found then render_room_not_found(params[:id])
        when :error_on_save        then render_error_on_save
        end
      end

      def list
        render :json => Room.all_live(current_user).map {|r| r.to_json }
      end

      def add_member
        render_login_error and return unless logged?

        Room.with_room(params[:id], current_user) do |room|
          render_room_not_found(params[:id]) and return if room.nil?

          user = User.find(params[:user_id])
          render_user_not_found(params[:user_id]) and return if user.nil?

          if room.members.include?(user)
            render_error "user already exists", 200
          else
            room.members << user
            if room.save then render :json => {:status => 'ok'}
                         else render_error "add user"
            end
          end
        end
      end
    end
  end
end
