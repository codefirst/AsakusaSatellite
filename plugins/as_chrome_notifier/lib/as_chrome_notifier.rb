require 'asakusa_satellite/hook'
class ChromeNotifierListener < AsakusaSatellite::Hook::Listener
  render_on :global_setting_item, :partial => "global_chrome_notifier_setting"

  def after_create_message(context)
    message = context[:message]
    room = context[:room]

    AsakusaSatellite::AsyncRunner.run do
      room.owner_and_members.each do |member|
        member.devices.each do |device|
          if device.device_type == "chrome" and device.name
            Chrome.send(device.name, message.id)
          end
        end
      end
    end
  end
end
