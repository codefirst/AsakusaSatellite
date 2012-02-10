require 'yaml'
require 'asakusa_satellite/message_pusher'

module ChatHelper
  def create_message(room, message, opt = {})
    return if !opt[:force] and message.strip.empty?

    @message = Message.new(:room_id => room._id, :room => room, :body => message, :user => current_user)
    unless @message.save
      return false
    end
    publish_message(:create, @message, room)
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
      publish_message(:create, message, room)
      message
    end
  end

  def update_message(message_id, message)
    @message = Message.where(:_id => message_id).first
    return false unless message
    @message.body = message
    if @message.save then
      publish_message(:update, @message, @message.room)
      true
    else
      false
    end
  end

  def delete_message(message_id)
    require 'pp'
    @message = Message.where(:_id => message_id).first
    return false unless @message
    return false unless @message.destroy

    publish_message(:delete, @message, @message.room)
    true
  end

  def to_json(message, room = message.room)
    view = render_to_string(:file   => "app/views/chat/_message.html.haml",
                            :locals => { :message => message, :room => room },
                            :layout => false)
    message.to_hash.merge( :view => view )
  end

  private
  def publish_message(event, message, room)
    data = if event == :delete then
             { :content => { :id => message.id } }
           else
             { :content => to_json(message, room) }
           end
    AsakusaSatellite::MessagePusher.trigger("as-#{room.id}",
                                            "message_#{event}",
                                            data.to_json)

    if event == :create then
      call_hook(:after_create_message, :message => message, :room => room)
    end
  end
end
