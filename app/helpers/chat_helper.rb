require 'yaml'
require 'asakusa_satellite/message_pusher'

module ChatHelper
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
  def publish_message(event, message, room)
    data = if event == :delete then
             { :content => { :id => message.id } }
           else
             { :content => to_json(message, room) }
           end

    begin
      AsakusaSatellite::MessagePusher.trigger("as-#{room.id}",
                                              "message_#{event}",
                                              data.to_json)
    rescue => e
      Rails.logger.warn "fail to send message: #{e.inspect}"
    end

    if event == :create then
      call_hook(:after_create_message, :message => message, :room => room)
    end
  end
end
