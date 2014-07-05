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

    device_tokens = devices.select(&:ios?).map(&:name)
    return if device_tokens.empty?

    apn_service = AsakusaSatellite::APNService.instance

    AsakusaSatellite::AsyncRunner.run do
      begin
        apn_service.send_message(device_tokens, room, text)
      rescue => e
        Rails.logger.error e
      end
    end
  end

end
