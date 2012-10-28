class Room
  include Mongoid::Document
  include Mongoid::Timestamps
#  field :updated_at, :type => Time
  field :title
  field :deleted, :type => Boolean, :default => false
  field :is_public, :type => Boolean, :default => true
  field :alternative_name
  field :yaml
  belongs_to :user, :polymorphic => true
  has_and_belongs_to_many :members, :class_name => 'User'

  validates_presence_of :title
  validates_format_of :alternative_name, :with => /\A[\w-]*\Z/

  validate :unique_if_not_blank, :alternative_name

  def unique_if_not_blank
    unless alternative_name.blank?
      size = Room.where(:alternative_name => alternative_name).where(:_id => {"$ne" => id}).size
      errors.add("room alias", I18n.t(:alternative_name_not_unique)) if size > 0
    end
  end

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

  def self.get(id, user = nil)
    room = Room.find(id)
    room if room.accessible?(user)
  end

  def messages(offset)
    Message.where("room_id" => id).order_by(:_id.desc).limit(offset).to_a.reverse
  end

  def messages_between(from_id, to_id, count)
    where = {:room_id => self.id}
    where[:_id.gte] = from_id if from_id
    where[:_id.lte] = to_id if to_id
    rel = Message.where(where)
    if (not from_id and to_id)
      rel = rel.order_by(:_id.desc)
    else
      rel = rel.order_by(:_id.asc)
    end
    rel.limit(count).to_a
  end

  def to_json
    {
      :id => self.id,
      :name => self.title,
      :updated_at => self.updated_at.to_s,
      :user => (self.user ? self.user.to_json : nil)
    }
  end

  def to_param
    if alternative_name.blank?
      id.to_s
    else
      alternative_name
    end
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

  def accessible?(user)
    self.is_public || (self.user == user) || (self.members.include? user)
  end
end
