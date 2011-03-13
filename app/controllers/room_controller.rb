class RoomController < ApplicationController
  def delete
    if request.post? and not current_user.nil?
      room = Room.find(params[:id])
      room.deleted = true
      room.save
    end
    redirect_to :controller => 'chat', :action => 'index'
  end

  def configure
    @id     = params[:id]
    @room ||= Room.find(params[:id])
    unless @room.user == current_user
      render :file=>"#{RAILS_ROOT}/public/403.html", :status=>'403 Forbidden'
    end

  end
end
