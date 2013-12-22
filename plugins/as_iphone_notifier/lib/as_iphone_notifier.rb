# -*- encoding: utf-8 -*-
require 'asakusa_satellite/hook'
class AsakusaSatellite::Hook::ASIPhoneNotifier < AsakusaSatellite::Hook::Listener

  def strip(str, n)
    escaped = str.to_json.match(/^"(.*)"$/)[1]
    len = 0
    s = escaped.scan(/((\\u[0-9a-f]{4})|(.))/).map(&:first).take_while{|escaped_char|
      len += escaped_char.length
      len <= n
    }.join
    (JSON.parse "[\"#{s}\"]")[0]
  end

  def after_create_message(context)
    message = context[:message]
    room = context[:room]

    not_attached = message.attachments.empty?

    body = not_attached ? message.body : message.attachments[0].filename
    text = strip "#{message.user.name} / #{body}", 150

    members = room.owner_and_members - [ message.user ]

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
  rescue => e
    Rails.logger.error e
  end

end
