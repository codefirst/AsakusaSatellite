class Setting
  @@available_settings = YAML.load(File.open("#{Rails.root}/config/settings.yml"))
  def self.[](key)
    @@available_settings[key.to_s]
  end
end
