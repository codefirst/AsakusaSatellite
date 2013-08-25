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
    return [] if offset <= 0
    Message.where(:room_id => self.room_id, :_id.lt => self._id).order_by(:_id.desc).limit(offset).to_a.reverse
  end

  def prev_id
    prev_messages = prev(1)
    return nil if prev_messages.empty?
    prev_messages.first.id
  end

  def next(offset)
    return [] if offset <= 0
    Message.where(:room_id => self.room_id, :_id.gt => self._id).order_by(:_id.asc).limit(offset).to_a
  end

  def self.make(user, room, message_body, allow_empty=false)
    return :login_error if user.nil?
    return :empty_message if not allow_empty and message_body.strip.empty?

    message = Message.new(:room => room, :body => message_body || "", :user => user)
    if message.save then message
                    else :error_on_save
    end
  end

  def self.update_body(user, message_id, message_body)
    return :login_error if user.nil?

    case message = Message.where(:user_id => user.id, :_id => message_id).first
    when Message
      message.body = message_body
      if message.save then message
                      else :error_on_save
      end
    else :error_message_not_found
    end
  end

  def self.delete(user, message_id)
    return :login_error if user.nil?

    case message = Message.where({:user_id => user.id, :_id => message_id}).first
    when Message
      if message.destroy then message
                         else :error_on_destroy
      end
    else :error_message_not_found
    end
  end

  def attach(file)
    max_size = Setting[:attachment_max_size].to_i
    return if max_size > 0 && file.size > max_size.megabyte

    filename = file.original_filename
    mimetype = file.content_type
    Attachment.create_and_save_file(file.original_filename, file, mimetype, self)
  end

  def accessible?(user)
    self.room and self.room.accessible?(user)
  end

  def self.find_by_text(params)
    query = params[:text]
    rooms = (params[:rooms] || Room.all_live).select {|room| not room.deleted}
    rooms.map do |room|
      condition = {:room_id => room._id, "$or" => [{:body => /#{query}/i}, {"attachments.filename" => /#{query}/i}]}
      condition.merge!({:_id.lt => params[:message_id]}) unless params[:message_id].blank?
      messages = Message.where(condition)
      messages = messages.limit(params[:limit]) if params[:limit]
      messages = messages.order_by(:_id.desc)
      { :room => room, :messages => messages }
    end
  end
end
