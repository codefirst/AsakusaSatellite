class Room
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title
  field :deleted, :type => Boolean
  field :yaml
  embeds_one :user

  validates_presence_of :title

  
  # get all rooms without deleted
  def self.all_live
    Room.where(:deleted => false) || []
  end

  def messages(offset)
    Message.where("room._id" => id).order_by(:created_at.desc).limit(offset).to_a.reverse
  end

  def to_json
    {
      :id => self.id,
      :name => self.title,
      :updated_at => self.updated_at.to_s,
      :user => (self.user ? self.user.to_json : nil)
    }
  end

  def yaml
    str = self.read_attribute("yaml")
    YAML.load(str) rescue {}
  end

  def yaml=(value)
    write_attribute("yaml", value.to_yaml)
  end

  def validate(options = {})
    (not self.title.blank?) and super(options)
  end
end
