class EmojiListener < AsakusaSatellite::Hook::Listener
  render_on :script_in_chat_room, :partial => "emoji_completer"
end
