# -*- encoding: utf-8 -*-
require 'asakusa_satellite/hook'
class AsakusaSatellite::Hook::ASIPhoneNotifier < AsakusaSatellite::Hook::Listener

  def strip(str, n)
    s = str.to_json.scan(/((\\u[0-9a-f]{4})|(.))/).map{|m| m[0]}.reduce(""){|x,y|
      z = x + y
      z.size <= n ? z : x
    }
    (JSON.parse "[#{s}]")[0]
  end

  def after_create_message(context)
    message = context[:message]
    room = context[:room]

    not_attached = message.attachments.empty?

    body = not_attached ? message.body : attachments[0].filename
    text = strip "#{message.user.name} / #{body}", 150

    members = room.members - [ message.user ]

    devices = members.map {|user|
      user.devices
    }.flatten

    iphones = devices.select do |device|
      device.device_type.nil? or device.device_type == 'iphone'
    end

    iphones.to_a.map{|iphone|
      APNS::Notification.new(iphone.name,
        :alert => text,
        :sound => 'default',
        :other => {
          :id => room.id
        })
    }.tap{|xs|
      APNS.send_notifications xs
    }
  end

end
