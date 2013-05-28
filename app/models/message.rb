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

  def next(offset)
    return [] if offset <= 0
    Message.where(:room_id => self.room_id, :_id.gt => self._id).order_by(:_id.asc).limit(offset).to_a
  end

  def self.make(user, room, message_body)
    return :login_error if user.nil?
    return :empty_message if message_body.strip.empty?

    message = Message.new(:room => room, :body => message_body, :user => user)
    if message.save then return message
                    else return :error_on_save
    end
  end

  def self.attach(user, room, params)
    max_size = Setting[:attachment_max_size].to_i
    return if max_size > 0 && params[:file].size > max_size.megabyte

    Message.new(:room => room, :body => nil, :user => user).tap do |message|
      return unless message.save
      Attachment.create_and_save_file(params[:filename], params[:file], params[:mimetype], message)
    end
  end

  def self.update(user, message_id, message_body)
    return :login_error if user.nil?

    Message.with_own_message(message_id, user) do |message|
      return :error_message_not_found unless message

      message.body = message_body
      if message.save then return message
                      else return :error_on_save
      end
    end
  end

  def self.delete(user, message_id)
    return :login_error if user.nil?

    Message.with_own_message(message_id, user) do |message|
      return :error_message_not_found unless message

      if message.destroy then return message
                         else return :error_on_destroy
      end
    end
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

  def self.with_message(id, conditions={}, &f)
    message = Message.where({:_id => id}.merge(conditions)).first
    unless message.nil? then
      f[message]
    else
      f[nil]
    end
  end

  def self.with_own_message(id, user, &f)
    return f[nil] if user.nil?
    with_message(id, {:user_id => user.id}, &f)
  end
end
