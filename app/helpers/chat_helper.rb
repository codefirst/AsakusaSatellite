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
      cache([message, :web], &block)
    end
  end

  def current_info(room)
    {
      :user => current_user && current_user.screen_name,
      :room => room.id.to_s,
      :public => room.is_public,
      :member => room.owner_and_members.map{|user| user._id}
    }
  end

  private
  def publish_message(event, message, room)
    data = if event == :delete
             { :content => { :id => message.id } }
           elsif event == :create
             { :content => to_json(message, room).merge({ :prev_id => message.prev_id }) }
           else
             { :content => to_json(message, room) }
           end

    AsakusaSatellite::AsyncRunner.run do
      begin
        AsakusaSatellite::MessagePusher.trigger("as-#{room.id}",
                                                "message_#{event}",
                                                data.to_json)
      rescue => e
        Rails.logger.warn "fail to send message: #{e.inspect}"
      end
    end

    if event == :create then
      call_hook(:after_create_message, :message => message, :room => room)
    end
  end
end
