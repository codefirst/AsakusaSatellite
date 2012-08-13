class Setting
  @@available_settings = YAML::load(ERB.new(File.read("#{Rails.root}/config/settings.yml")).result)
  def self.[](key)
    @@available_settings[key.to_s]
  end
end
