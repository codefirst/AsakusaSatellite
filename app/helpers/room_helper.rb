module RoomHelper
  def find_room(id, params={}, &f)
    Room.with_room(id, current_user, params) {|room| @room = room}
    if @room.nil?
      flash[:error] = t(:error_room_deleted)
      redirect_to :controller => 'chat', :action => 'index'
    else
      f[]
    end
  end
end
