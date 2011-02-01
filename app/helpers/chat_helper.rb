require 'open-uri'
require 'yaml'

module ChatHelper
  def create_message(room_id, message, opt = {})
    return if !opt[:force] and message.strip.empty?

    room = Room.find(room_id)
    @message = Message.new(:room => room, :body => message, :user => current_user)
    unless @message.save
      return false
    end
    publish_message(:create, @message)
    @message
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
    Thread.new do
      open("http://localhost:#{WebsocketConfig.httpPort}/message/#{event}/#{message.id}"){|_|}
    end
  end
end
