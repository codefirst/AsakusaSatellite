# -*- encoding: utf-8 -*-
require 'asakusa_satellite/hook'
class AsakusaSatellite::Hook::ASIPhoneNotifier < AsakusaSatellite::Hook::Listener

  def after_create_message(context)
    message = context[:message]
    room = context[:room]

    members = room.owner_and_members - [ message.user ]
    devices = members.map { |user| user.devices }.flatten
    device_tokens = devices.select(&:ios?).map(&:name)
    return if device_tokens.empty?

    apn_service = AsakusaSatellite::APNService.instance

    AsakusaSatellite::AsyncRunner.run do
      begin
        apn_service.send_message(device_tokens, room, message)
      rescue => e
        Rails.logger.error e
      end
    end
  end

end
