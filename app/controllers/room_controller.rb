# -*- coding: utf-8 -*-
require 'lib/asakusa_satellite/config'
class RoomController < ApplicationController
  include RoomHelper

  def create
    if current_user.nil?
      redirect_to :controller => 'chat'
    elsif request.post?
      room = Room.new(:title => params[:room][:title],
                      :user => current_user,
                      :updated_at => Time.now,
                      :deleted => false,
                      :is_public => (params[:room][:is_public] != '0')) # "0" のとき以外はtrue
      if room.save
        redirect_to :controller => :chat, :action => 'room', :id => room.id
      else
        flash[:error] = t(:error_room_cannot_create)
        redirect_to :action => 'create'
      end
    end
  end

  def delete
    @id = params[:id]

    if request.post?
      find_room(@id) do
        @room.deleted = true
        @room.save!
        redirect_to :controller => 'chat', :action => 'index'
      end
    else
      redirect_to :controller => 'chat', :action => 'index'
    end
  end

  def configure
    @id      = params[:id]
    @plugins = AsakusaSatellite::Config.rooms
    find_room(@id) do
      puts 1
      if request.post? then
        @room.title = params[:room][:title] unless params[:room][:title].blank?
        unless params[:room][:members].blank?
          params[:room][:members].each do |_, user_name|
            puts user_name
            user = User.where(:screen_name => user_name).first
            next if user.nil?
            next if include_member(@room, user)
            puts user.screen_name
            puts user.name
            @room.members << user
          end
        end
        @room.save
      end
    end
  end

  private
  def include_member(room, user)
    return false if room.nil?
    return false if room.members.nil?
    room.members.each do |member|
      return true if member.id.to_s == user.id.to_s
    end
    false
  end

end
