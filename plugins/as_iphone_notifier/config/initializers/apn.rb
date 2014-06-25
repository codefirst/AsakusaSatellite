instance = AsakusaSatellite::APNService.instance
Device.add_after_save do |device|
  instance.register(device)
end
Device.add_after_destroy do |device|
  instance.unregister(device)
end

