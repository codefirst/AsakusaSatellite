require 'yaml'
require 'pusher'

Pusher.app_id = '7241'
Pusher.key    = 'f36e789c57a0fc0ef70b'
Pusher.secret = '1c66d57d4868ff817d5d'

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
    require 'pp'
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
    channel = Pusher["as:#{message.room.id}"]

    if event == :delete then
      channel.trigger("message_#{event}",
                      {
                        :content => { :id => message.id }
                      }.to_json)
    else
      channel.trigger("message_#{event}",
                      {
                        :content => to_json(message)
                      }.to_json)
    end

    if event == :create then
      text = "#{message.user.name} / #{message.body}"[0,150]

      members = message.room.members - [ message.user ]
      android,iphone = members.map {|user| user.devices }.flatten.map {|device|
        device.device_type == 'android'
      }

      iphone.map{|device|
        APNS::Notification.new(device.name,
                               :alert => text,
                               :sound => 'default',
                               :other => {
                                 :id => message.room.id
                               })
      }.tap{|xs|
        APNS.send_notifications xs
      }

      android.map{|device|
        { :registration_id => device.name,
          :data => {
            :message => text
          }
        }
      }.tap{|xs|
        C2DM.send_notifications(ENV[:android_mail_address],
                                ENV[:android_password],
                                xs,
                                ENV[:android_application_name])
      }

    end
  end
end
