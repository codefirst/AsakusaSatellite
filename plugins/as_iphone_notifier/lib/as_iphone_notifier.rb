# -*- encoding: utf-8 -*-
require 'asakusa_satellite/hook'
class AsakusaSatellite::Hook::ASIPhoneNotifier < AsakusaSatellite::Hook::Listener

  def strip(str, n)
    str.to_json.scan(/./).reduce(""){|x,y|
      x.size < n ? x + y : x
    }
  end

  def after_create_message(context)
    message = context[:message]
    room = context[:room]

    text = strip "#{message.user.name} / #{message.body}", 256

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
