# -*- coding: utf-8 -*-
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :screen_name
  field :email
  field :profile_image_url
  field :spell
  embeds_many :devices
  has_many :rooms, :as => :own_rooms
  has_and_belongs_to_many :rooms, :class_name => 'Room'

  def to_json
    {
      :id => self.id,
      :name => self.name,
      :screen_name => self.screen_name,
      :profile_image_url => self.profile_image_url,
    }
  end

  def register_spell
    self.spell = generate_spell
    self.save
  end

#  private
  def generate_spell
    length = (20..30).to_a.sample
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    Array.new(length) { chars[rand(chars.size)] }.join
  end

end
