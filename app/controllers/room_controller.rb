class RoomController < ApplicationController
  def delete
    room = Room.find(params[:id])
    room.deleted = true
    room.save
    redirect_to :controller => 'chat', :action => 'index'
  end
end
