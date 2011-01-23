module ChatHelper
  def create_message(room_id, message)
    room = Room.find(room_id)
    @message = Message.new(:room => room, :body => message, :user => User.current)
    unless @message.save
      return false
    end
    true
  end

  def update_message(message_id, message)
    @message = Message.find(message_id)
    return false unless message
    @message.body = message
    unless @message.save
      return false
    end
    true
  end

  def delete_message(message_id)
    @message = Message.find(message_id)
    unless @message.destroy
      return false
    end
    true
  end

end
