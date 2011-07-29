require 'yaml'
require 'msgpack-rpc'

class BSON::ObjectId
  def to_msgpack(*args)
    self.to_s.to_msgpack(*args)
  end
end

module ChatHelper
  def create_message(room_id, message, opt = {})
    return if !opt[:force] and message.strip.empty?

    room = Room.where(:_id => room_id).first
    @message = Message.new(:room_id => room_id, :room => room, :body => message, :user => current_user)
    unless @message.save
      return false
    end
    publish_message(:create, @message)
    @message
  end

  def create_attach(room_id, params)
    room = Room.where(:_id => room_id).first
    message = Message.new(:room => room, :body => message, :user => current_user)
    unless message.save
      return false
    else
      Attachment.create_and_save_file(params[:filename],
                                      params[:file],
                                      params[:mimetype],
                                      message)
      publish_message(:create, message)
      message
    end
  end

  def update_message(message_id, message)
    @message = Message.where(:_id => message_id).first
    return false unless message
    @message.body = message
    if @message.save then
      publish_message(:update, @message)
      true
    else
      false
    end
  end

  def delete_message(message_id)
    @message = Message.where(:_id => message_id).first
    return false unless @message
    return false unless @message.destroy

    publish_message(:delete, @message)
    true
  end

  def to_json(message)
    view = render_to_string(:file   => "app/views/chat/_message.html.haml",
                            :locals => { :message => message },
                            :layout => false)
    message.to_hash.merge( :view => view )
  end

  private
  def publish_message(event, message)
    @client = MessagePack::RPC::Client.new('127.0.0.1', WebsocketConfig.msgpackPort)
    Thread.start do
      begin
        if event == :delete then
          @client.call("message_#{event}".to_sym, message.room.id, message.id)
        else
          @client.call("message_#{event}".to_sym, message.room.id, to_json(message))
        end
      rescue => e
        puts e
      end
    end
  end
end
