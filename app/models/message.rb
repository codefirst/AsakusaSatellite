# -*- coding: utf-8 -*-
class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :created_at, :type => Time
  field :body
  belongs_to :room
  belongs_to :user
  embeds_many :attachments
  index :created_at

  def encode_json(_)
    self.to_hash.to_json
  end

  def to_hash
    {
      'id'   => self.id,
      'body' => self.body,
      'html_body' => self.html_body(self.room),
      'name' => (self.user ? self.user.name : 'Anonymous User'),
      'screen_name' => (self.user ? self.user.screen_name : 'Anonymous User'),
      'profile_image_url' => (self.user ? self.user.profile_image_url : ''),
      'created_at' => self.created_at.to_s,
      'room'       => self.room.to_json,
      'attachment' => self.attachments && self.attachments.map {|a| a.to_hash}
    }
  end

  def html_body(room)
    AsakusaSatellite::Filter.process self, room || self.room
  end

  def prev(offset)
    Message.where(:room_id => self.room_id, :_id.lt => self._id).order_by(:_id.desc).limit(offset).to_a.reverse
  end

  def next(offset)
    Message.where(:room_id => self.room_id, :_id.gt => self._id).order_by(:_id.asc).limit(offset).to_a
  end

  def self.find_by_text(params)
    query = params[:text]
    rooms = (params[:rooms] || Room.all_live).select {|room| not room.deleted}
    rooms.map do |room|
      messages = Message.where(:room_id => room._id, :body => /#{query}/i).order_by(:_id.desc)
      { :room => room, :messages => messages }
    end
  end
end

