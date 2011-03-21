# -*- coding: utf-8 -*-
class Message < ActiveGroonga::Base
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
      'attachment' => self.attachment && self.attachment.to_hash
    }
  end

  def html_body
    AsakusaSatellite::Filter.process self.body.to_s
  end

  def attachment
    attachments = Attachment.select do |record|
      record.message == self
    end
    attachments.nil? ? nil : attachments.first
  end

  def prev(offset)
    # FIXME: もっと効率良く!
    Message.select do |record|
      (record.id < self.id) & (record.room == self.room)
    end.sort([{:key => "created_at", :order => :desc}], :limit => offset).to_a.reverse
  end

  def next(offset)
    # FIXME: もっと効率良く!
    Message.select do |record|
      (record.id > self.id) & (record.room == self.room)
    end.sort([{:key => "created_at", :order => :asc}], :limit => offset).to_a
  end

  def self.find_by_text(params)
    query = params[:text]
    rooms = params[:rooms] || Room.all_live

    rooms.map do |room|
      messages = Message.select do |record|
        [record.room == room, record["body"] =~ query]
      end
      { :room => room, :messages => messages }
    end
  end
end

