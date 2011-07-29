# -*- coding: utf-8 -*-
class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body
  field :room_id
  embeds_one :room
  embeds_one :user
  index :updated_at

  def encode_json(_)
    self.to_hash.to_json
  end

  def to_hash
    {
      'id'   => self.id,
      'body' => self.body,
      'html_body' => self.html_body,
      'name' => (self.user ? self.user.name : 'Anonymous User'),
      'screen_name' => (self.user ? self.user.screen_name : 'Anonymous User'),
      'profile_image_url' => (self.user ? self.user.profile_image_url : ''),
      'created_at' => I18n.l(self.created_at),
      'room'       => self.room.to_json,
      'attachment' => self.attachment && self.attachment.to_hash
    }
  end

  def html_body
    AsakusaSatellite::Filter.process self.body.to_s
  end

  def attachment
    attachments = Attachment.where(:message_id => self.id)
    attachments.nil? ? nil : attachments.first
  end

  def prev(offset)
    Message.where(:_id.lt => self._id, "room._id" => room.id).order_by(:created_at.desc).limit(offset).to_a.reverse
  end

  def next(offset)
    Message.where(:_id.gt => self._id, "room._id" => room.id).order_by(:created_at.asc).limit(offset).to_a
  end

  def self.find_by_text(params)
    query = params[:text]
    rooms = params[:rooms] || Room.all_live
    rooms.map do |room|
      messages = Message.where("room._id" => room.id, :body => /#{query}/i)
      { :room => room, :messages => messages }
    end
  end
end

