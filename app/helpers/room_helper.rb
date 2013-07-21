module RoomHelper
  def find_room(id, params={}, &f)
    Room.with_room(id, current_user, params) do |room|
      if room.nil?
        flash[:error] = t(:error_room_deleted)
        redirect_to :controller => 'chat', :action => 'index'
      else
        f[room]
      end
    end
  end
end
