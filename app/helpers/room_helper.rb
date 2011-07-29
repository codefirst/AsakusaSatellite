module RoomHelper
  def find_room(id, params={}, &f)
    @room = Room.find(id)
    case
    when @room == nil
      flash[:error] = t(:error_room_deleted)
      redirect_to :action => 'index'
    when @room.deleted
      flash[:error] = t(:error_room_deleted)
      redirect_to :controller => 'chat', :action => 'index'
    when params[:not_auth] != true && current_user == nil
      flash[:error] = t(:error_room_deleted)
      redirect_to :controller => 'chat', :action => 'index'
    else
      f[]
    end
  end
end
