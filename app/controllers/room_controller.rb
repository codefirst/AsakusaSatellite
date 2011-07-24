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
                      :deleted => false)
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
      if request.post? then
        @room.update_attributes! params[:room]
      end
    end
  end
end
