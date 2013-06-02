module RoomHelper
  def find_room(id, params={}, &f)
    with_room(id, params) do|r|
      @room = r
      if r.nil? then
        flash[:error] = t(:error_room_deleted)
        redirect_to :controller => 'chat', :action => 'index'
      else
        f[]
      end
    end
  end

  def with_room(id, params={}, &f)
    return f[nil] if id.blank?

    room = Room.where(:_id => id).first || Room.where(:nickname => id).first
    if (room == nil) or
        room.deleted or
        (not room.accessible?(current_user)) or
        (params[:not_auth] != true && current_user == nil) then
      f[nil]
    else
      f[room]
    end
  end
end
