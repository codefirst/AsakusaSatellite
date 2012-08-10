# -*- coding: utf-8 -*-
require 'uuidtools'
class Attachment
  UPLOAD_DIR = "#{Rails.root}/#{Setting[:attachment_path]}"

  include Mongoid::Document
  include Mongoid::Timestamps
  field :disk_filename
  field :filename
  field :content_type
  field :mimetype
  field :message_id
  embedded_in :message, :inverse_of => :attachments

  def to_hash
    {
      :disk_filename => File.basename(self.disk_filename),
      :filename => self.filename,
      :content_type => self.mimetype
    }
  end

  def self.create_and_save_file(filename, file, mimetype, message)
    disk_filename = unique_id + "-" + filename
    open("#{UPLOAD_DIR}/#{disk_filename}", "wb") do |f|
      f.write(file.read)
    end
    attachment = Attachment.new(:filename => filename,
                                :mimetype => mimetype,
                                :disk_filename => "#{UPLOAD_DIR}/#{disk_filename}",
                                :message => message)
    attachment.save
    attachment
  end

  def self.unique_id
    UUIDTools::UUID.random_create.to_s
  end
end
