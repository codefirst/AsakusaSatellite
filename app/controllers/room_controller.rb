# -*- coding: utf-8 -*-
require 'lib/asakusa_satellite/config'
class RoomController < ApplicationController
  include RoomHelper
  def delete
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
    @id     = params[:id]
    @plugins = AsakusaSatellite::Config.rooms

    find_room(@id) do
      if request.post? then
        @room.update_attributes! params[:room]
      end
    end
  end

  def join
    @id     = params[:id]
    find_room(@id) do
      if @room.joined? current_user then
        @room.leave current_user
        render :json => { :member => false }
      else
        @room.join current_user
        render :json => { :member => true }
      end
    end
  end
end
