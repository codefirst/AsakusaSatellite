# -*- encoding: utf-8 -*-
module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper
      include ApiHelper
      include RoomHelper

      before_filter :check_spell, :except => [:list]

      respond_to :json
      def create
        room = Room.new(:title => params[:name], :user => current_user, :updated_at => Time.now)
        if room.save
          render :json => {:status => 'ok', :room_id => room._id}
        else
          render :json => {:status => 'error', :error => "room creation failure"}
        end
      end

      def update
        with_room(params[:id]) do|room|
          if room.nil?
            render :json => {:status => 'error', :error => "room not found"}
          elsif room.update_attributes(:title => params[:name])
            render :json => {:status => 'ok'}
          else
            render :json => {:status => 'error', :error => "room creation failure"}
          end
        end
      end

      def destroy
        with_room(params[:id]) do|room|
          if room.nil?
            render :json => {:status => 'error', :error => "room not found"}
          elsif room.update_attributes(:deleted => true)
            render :json => {:status => 'ok'}
          else
            render :json => {:status => 'error', :error => "room deletion failure"}
          end
        end
      end

      def list
        if params[:api_key].blank?
          render :json => Room.all_live.map {|r| r.to_json }
          return
        end

        if check_spell
          render :json => Room.all_live(current_user).map {|r| r.to_json }
        else
          render :json => {:status => 'error', :error => "login failure"}
        end
      end

      def add_member
        with_room(params[:id]) do|room|
          user = User.find(params[:user_id])
          if room.nil?
            render :json => {:status => 'error', :error => "room not found"}
            return
          elsif user.nil?
            render :json => {:status => 'error', :error => "user not found"}
            return
          end

          room.members ||= []
          member = room.members.where(:_id => user.id).first
          unless member.nil?
            render :json => {:status => 'error', :error => "user already exists"}
            return
          end

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
