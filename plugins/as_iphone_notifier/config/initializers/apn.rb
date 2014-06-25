instance = AsakusaSatellite::APNService.instance
Device.add_after_save(lambda { |device|
  instance.register(device)
})
Device.add_after_destroy(lambda { |device|
  instance.unregister(device)
})

