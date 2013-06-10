require 'asakusa_satellite/hook'
class ChromeNotifierListener < AsakusaSatellite::Hook::Listener
  render_on :global_setting_item, :partial => "global_chrome_notifier_setting"

  def after_create_message(context)
    message = context[:message]
    room = context[:room]

    (room.owner_and_members - [message.user]).each do |member|
      Chrome.where(:user_id => member.id).each do |chrome|
        Chrome.send(chrome.channel_id, message.id)
      end
    end

  end
end
