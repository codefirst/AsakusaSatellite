class Room
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title
  field :deleted, :type => Boolean, :default => false
  field :is_public, :type => Boolean, :default => true
  field :yaml
  belongs_to :user, :polymorphic => true
  has_and_belongs_to_many :members, :class_name => 'User'

  validates_presence_of :title

  def self.public_rooms
    Room.where(:is_public => true, :deleted => false).to_a
  end

  def self.member_rooms(user)
    Room.where(:is_public => false, :deleted => false).select do |room|
      room.members.any? {|u| u.id == user.id}
    end.to_a
  end

  def self.owner_rooms(user)
    Room.where(:deleted => false, 'user_id' => user.id).to_a
  end

  # get all rooms without deleted
  def self.all_live(user = nil)
    xs = if user then
           public_rooms + member_rooms(user) + owner_rooms(user)
         else
           public_rooms
         end
    xs.uniq
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
