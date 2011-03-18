class LocalUser
  @@users = YAML.load(File.open("#{File.dirname(__FILE__)}/../../config/users.yml"))
  def self.[](key)
    @@users[key]
  end
end
