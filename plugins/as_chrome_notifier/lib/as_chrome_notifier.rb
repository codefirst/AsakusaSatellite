require 'asakusa_satellite/hook'
class ChromeNotifierListener < AsakusaSatellite::Hook::Listener
  render_on :global_setting_item, :partial => "global_chrome_notifier_setting"

  def after_create_message(context)
    message = context[:message]
    room = context[:room]

    (room.owner_and_members - [message.user]).each do |member|
      member.devices.each do |device|
        channel_id = device.name
        Chrome.send(channel_id, message.id) unless channel_id.nil?
      end
    end
  end
end
