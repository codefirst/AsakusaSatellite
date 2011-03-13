# -*- coding: utf-8 -*-
require 'lib/asakusa_satellite/config'
class RoomController < ApplicationController
  include RoomHelper
  def delete
    if request.post?
      find_room(@id) do
        @room.deleted = true
        @room.save!
      end
    end
    redirect_to :controller => 'chat', :action => 'index'
  end

  def configure
    @id     = params[:id]
    @plugins = AsakusaSatellite::Config.rooms
    p @plugins
    find_room(@id) do
      if request.post? then
        @room.update_attributes! params[:room]
      end
    end
  end
end
