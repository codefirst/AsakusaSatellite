class ProfileSettingListener < AsakusaSatellite::Hook::Listener
  render_on :account_setting_item, :partial => "profile_setting"
end

