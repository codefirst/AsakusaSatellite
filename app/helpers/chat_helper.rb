require 'yaml'
require 'pusher'

Pusher.app_id = '7241'
Pusher.key    = 'f36e789c57a0fc0ef70b'
Pusher.secret = '1c66d57d4868ff817d5d'

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
    channel = Pusher["as:#{room.id}"]

    if event == :delete then
      channel.trigger("message_#{event}",
                      {
                        :content => { :id => message.id }
                      }.to_json)
    else
      channel.trigger("message_#{event}",
                      {
                        :content => to_json(message, room)
                      }.to_json)
    end

    if event == :create then
      text = "#{message.user.name} / #{message.body}"[0,150]

      members = room.members - [ message.user ]
      devices = members.map {|user|
        user.devices
      }.flatten
      android,iphone = devices.partition {|device|
        device.device_type == 'android'
      }

      iphone.to_a.map{|device|
        APNS::Notification.new(device.name,
                               :alert => text,
                               :sound => 'default',
                               :other => {
                                 :id => room.id
                               })
      }.tap{|xs|
        APNS.send_notifications xs
      }

      android.to_a.map{|device|
        { :registration_id => device.name,
          :data => {
            :message => text,
            :id => room.id
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
