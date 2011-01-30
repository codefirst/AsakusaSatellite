class Setting
  @@available_settings = YAML.load(File.open("#{RAILS_ROOT}/config/settings.yml"))
  def self.[](key)
    @@available_settings[key.to_s]
  end
end
