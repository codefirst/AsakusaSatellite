# -*- coding: utf-8 -*-
class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :created_at
  field :body
  field :room_id
  embeds_one :room
  embeds_one :user
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
      'created_at' => I18n.l(self.created_at),
      'room'       => self.room.to_json,
      'attachment' => self.attachments && self.attachments.map {|a| a.to_hash}
    }
  end

  def html_body(room)
    AsakusaSatellite::Filter.process self, room
  end

  def prev(offset)
    Message.where("room._id" => self.room.id, :_id.lt => self._id).order_by(:_id.desc).limit(offset).to_a.reverse
  end

  def next(offset)
    Message.where("room._id" => self.room.id, :_id.gt => self._id).order_by(:_id.asc).limit(offset).to_a
  end

  def self.find_by_text(params)
    query = params[:text]
    rooms = params[:rooms] || Room.all_live
    rooms.map do |room|
      messages = Message.where('room._id' => room.id, 'room.deleted' => false, :body => /#{query}/i)
      { :room => room, :messages => messages }
    end
  end
end

