class RoomController < ApplicationController
  def delete
    if request.post?
      room = Room.find(params[:id])
      room.deleted = true
      room.save
    end
    redirect_to :controller => 'chat', :action => 'index'
  end
end
