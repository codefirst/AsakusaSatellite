module RoomHelper
  def find_room(id, params={}, &f)
    @room = Room.where(:_id => id).first
    @room ||= Room.where(:alias => id).first unless id.blank?
    if (@room == nil) or
        @room.deleted or
        (not @room.accessible?(current_user)) or
        (params[:not_auth] != true && current_user == nil) then
      flash[:error] = t(:error_room_deleted)
      redirect_to :controller => 'chat', :action => 'index'
    else
      f[]
    end
  end
end
