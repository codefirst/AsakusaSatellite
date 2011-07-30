class Room
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title
  field :deleted, :type => Boolean, :default => false
  field :yaml
  belongs_to :user, :polymorphic => true
  has_and_belongs_to_many :members, :class_name => 'User'

  validates_presence_of :title

  # get all rooms without deleted
  def self.all_live
    Room.where(:deleted => false) || []
  end

  def messages(offset)
    Message.where("room._id" => id).order_by(:_id.desc).limit(offset).to_a.reverse
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
