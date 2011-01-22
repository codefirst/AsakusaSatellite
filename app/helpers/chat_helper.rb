module ChatHelper
  def create_message(room_id, message)
    room = Room.find(room_id)
    @message = Message.new(:room => room, :body => message, :user => User.current)
    unless @message.save
      # TODO: error handling
    end
  end

end
