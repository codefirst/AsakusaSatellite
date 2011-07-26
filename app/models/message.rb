# -*- coding: utf-8 -*-
class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body
  field :room_id
  embeds_one :room
  embeds_one :user

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
    # FIXME: もっと効率良く!
    Message.where(:created_at.lt => created_at, "room._id" => room.id).order_by(:created_at.desc).limit(offset).to_a.reverse

    # Message.select do |record|
    #   (record.id < self.id) & (record.room == self.room)
    # end.sort([{:key => "created_at", :order => :desc}], :limit => offset).to_a.reverse
  end

  def next(offset)
    # FIXME: もっと効率良く!
    Message.where(:created_at.gt => created_at, "room._id" => room.id).order_by(:created_at.asc).limit(offset).to_a
    # Message.select do |record|
    #   (record.id > self.id) & (record.room == self.room)
    # end.sort([{:key => "created_at", :order => :asc}], :limit => offset).to_a
  end

  def self.find_by_text(params)
    query = params[:text]
    rooms = params[:rooms] || Room.all_live
    puts query
    rooms.map do |room|
      messages = Message.where("room._id" => room.id, :body => /#{query}/i)
      { :room => room, :messages => messages }
    end
  end
end

