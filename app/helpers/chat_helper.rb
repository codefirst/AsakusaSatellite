require 'yaml'
require 'asakusa_satellite/message_pusher'

module ChatHelper
  def create_message(room, message)
    save_message(room, message){|_|}
  end

  def create_attach(room, params)
    save_message(room, nil){|m|
      Attachment.create_and_save_file(params[:filename],
                                      params[:file],
                                      params[:mimetype],
                                      m)
    }
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
    @message = Message.where(:_id => message_id).first
    return false unless @message
    return false unless @message.destroy

    publish_message(:delete, @message, @message.room)
    true
  end

  def to_json(message, room = message.room)
    view = render_to_string(:file    => "app/views/chat/_message",
                            :locals  => { :message => message, :room => room },
                            :formats => [ :html ],
                            :layout  => false)
    message.to_hash.merge( :view => view )
  end

  def cache_message(message, has_class, &block)
    if has_class
      block.call
    else
      cache(message, &block)
    end
  end

  private
  def save_message(room, body, &f)
    Message.new(:room => room, :body => body, :user => current_user).
      tap{|m| return false unless m.save }.
      tap{|m| f[m] }.
      tap{|m| publish_message(:create, m, room) }
  end

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
