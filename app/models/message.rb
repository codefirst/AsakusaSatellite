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
    Message.select('id, room.id, user.id, body') do |record|
      record.id < self.id
    end.sort([{:key => "created_at", :order => :desc}], :limit => offset).to_a.reverse
  end

  def next(offset)
    # FIXME: もっと効率良く!
    next_ = Message.select('id, room.id, user.id, body') do |record|
      record.id > self.id
    end.sort([{:key => "created_at", :order => :asc}], :limit => offset).to_a
  end
end

