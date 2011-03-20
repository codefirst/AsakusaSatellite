# -*- coding: utf-8 -*-
require 'uuidtools'
class Attachment < ActiveGroonga::Base
  UPLOAD_DIR = "#{Rails.root}/public/upload"
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
