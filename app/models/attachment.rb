# -*- coding: utf-8 -*-
require 'uuidtools'
require 'net/https'
require 'uri'
require 'json'
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
    if Setting[:attachment_path].start_with? "http"
      uri = URI.parse Setting[:attachment_path]
      response_str = RestClient.post uri.to_s, { "upload[file]" => file }
      response = JSON.parse response_str
      filepath = response["source"]
    else
      filepath = "#{UPLOAD_DIR}/#{unique_id}-#{filename}"
      open(filepath, "wb") do |f|
        f.write(file.read)
      end
    end

    attachment = Attachment.new(:filename => filename,
                                :mimetype => mimetype,
                                :disk_filename => filepath,
                                :message => message)
    attachment.save
    attachment
  end

  def self.unique_id
    UUIDTools::UUID.random_create.to_s
  end
end
