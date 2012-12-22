class DeviceSettingListener < AsakusaSatellite::Hook::Listener
  render_on :account_setting_item, :partial => "device_setting"
end

