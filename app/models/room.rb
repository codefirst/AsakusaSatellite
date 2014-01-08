class Room
  include Mongoid::Document
  include Mongoid::Timestamps
#  field :updated_at, :type => Time
  field :title
  field :deleted, :type => Boolean, :default => false
  field :is_public, :type => Boolean, :default => true
  field :nickname
  field :yaml
  belongs_to :user, :polymorphic => true
  has_and_belongs_to_many :members, :class_name => 'User'

  validates_presence_of :title
  validates_format_of :nickname, :with => /\A[\w-]*\Z/

  validate :unique_if_not_blank, :nickname

  def unique_if_not_blank
    unless nickname.blank?
      is_duplicated = Room.where(:nickname => nickname).where(:_id => {"$ne" => id}).any?
      errors.add("room nickname", I18n.t(:nickname_not_unique)) if is_duplicated
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

  def owner_and_members
    if self.is_public
    then []
    else [self.user] + self.members
    end
  end

  def messages(count, order = nil)
    rel = Message.where("room_id" => id)
    if order == nil or order == :desc
      rel = rel.order_by(:_id.desc)
    else
      rel = rel.order_by(:_id.asc)
    end
    ret = rel.limit(count).to_a
    ret.reverse! if order == nil
    ret
  end

  def messages_between(from, to, count, order = nil)
    conditions = {:room_id => self.id}
    if from
      conditions[:_id.gte] = from[:id] if     from[:include_boundary]
      conditions[:_id.gt]  = from[:id] unless from[:include_boundary]
    end
    if to
      conditions[:_id.lte] = to[:id] if     to[:include_boundary]
      conditions[:_id.lt]  = to[:id] unless to[:include_boundary]
    end

    rel = Message.where(conditions)
    only_to_id = ((not from) and to)
    if order == :desc or only_to_id
      rel = rel.order_by(:_id.desc)
    else
      rel = rel.order_by(:_id.asc)
    end
    ret = rel.limit(count).to_a
    ret.reverse! if order == :asc and only_to_id
    ret
  end

  def to_json
    {
      :id => self.id,
      :name => self.title,
      :nickname => self.nickname,
      :updated_at => self.updated_at.to_s,
      :user => (self.user ? self.user.to_json : nil)
    }
  end

  def to_param
    if nickname.blank?
      id.to_s
    else
      nickname
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
    return false if self.deleted
    self.is_public || (self.user == user) || (self.members.include? user)
  end

  def self.with_room(id, user, params={}, &f)
    return f[nil] if id.blank?

    room = Room.any_of({:_id => id}, {:nickname => id}).first
    if room and room.accessible?(user) then
      f[room]
    else
      f[nil]
    end
  end

  def self.make(name, owner, attributes={})
    return :login_error if owner.nil?

    room = Room.new(:title => name, :user => owner, :update_at => Time.now)
    if room.update_attributes(attributes) then room
                                          else :error_on_save
    end
  end

  def self.configure(id, user, attributes)
    return :login_error if user.nil?

    with_room(id, user) do |room|
      return :error_room_not_found if room.nil?

      if room.update_attributes(attributes) then room
                                            else :error_on_save
      end
    end
  end

  def self.delete(id, user)
    self.configure(id, user, :deleted => true)
  end
end
