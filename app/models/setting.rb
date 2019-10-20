class Setting
  class << self
    def settings_path
      name = "#{ENV['SETTINGS'] || 'settings'}.yml"
      Rails.root.join('config', name)
    end
  end

  @@available_settings = YAML::load(ERB.new(File.read(settings_path)).result)

  def self.[](key)
    @@available_settings[key.to_s]
  end
end
