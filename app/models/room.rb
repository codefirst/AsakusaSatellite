class Room < ActiveGroonga::Base

  # get all rooms without deleted
  def self.all_live
    Room.select do |record|
      record.deleted == false
    end || []
  end

  def messages(offset)
    Message.select do |record|
      record.room == self.id
    end.sort([{:key => "created_at", :order => :desc}],:limit => offset).to_a.reverse
  end

  def to_json
    {
      :id => self.id,
      :name => self.title,
      :updated_at => self.updated_at,
      :user => (self.user ? self.user.to_json : nil)
    }
  end

  def yaml
    str =  self.read_attribute("yaml")
    begin
      YAML.load str
    rescue
      {}
    end
  end

  def yaml=(value)
    write_attribute "yaml", value.to_yaml
  end

  def validate(options = {})
    (not self.title.blank?) and super(options)
  end
end
