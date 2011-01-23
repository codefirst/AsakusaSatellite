require 'open-uri'

module ChatHelper
  def create_message(room_id, message)
    room = Room.find(room_id)
    @message = Message.new(:room => room, :body => message, :user => User.current)
    unless @message.save
      return false
    end
    publish_message(:create, @message)
    true
  end

  def update_message(message_id, message)
    @message = Message.find(message_id)
    return false unless message
    @message.body = message
    unless @message.save
      return false
    end
    publish_message(:update, @message)
    true
  end

  def delete_message(message_id)
    @message = Message.find(message_id)
    unless @message.destroy
      return false
    end
    publish_message(:delete, @message)
    true
  end

  private
  def publish_message(event, message)
    puts message
    fork {
      open("http://localhost:8081/message/#{event}/#{message.id}"){|_|}
    }
  end
end
