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
  has_and_belongs_to_many :rooms, :as => :joined_rooms
  
  
  def to_json
    {
      :id => self.id,
      :name => self.name,
      :screen_name => self.screen_name,
      :profile_image_url => self.profile_image_url,
    }
  end
end
