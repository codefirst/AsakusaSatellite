# -*- coding: utf-8 -*-
require 'uuidtools'

class Attachment
  class << self
    def create_and_save_file(filename, file, mimetype, message)
      permalink, disk_filename = policy.upload(filename, file, mimetype, message)
      Attachment.new(:filename => filename,
                     :mimetype => mimetype,
                     :permalink => permalink,
                     :disk_filename => disk_filename,
                     :message => message).tap{|a|
        a.save }
    end

    def register(name, klass)
      @@policy ||= {}
      @@policy[name] = klass
    end

    private
    def policy
      @@policy[Setting[:attachment_policy] || 'local'].new
    end
  end

  include Mongoid::Document
  include Mongoid::Timestamps
  field :disk_filename
  field :permalink
  field :filename
  field :content_type
  field :mimetype
  field :message_id
  embedded_in :message, :inverse_of => :attachments

  def to_hash
    {
      :disk_filename => File.basename(self.disk_filename || '' ),
      :filename => self.filename,
      :content_type => self.mimetype
    }
  end

  def url
    self.permalink || LocalStorePolicy.url_for_localfile(self.disk_filename)
  end

  class LocalStorePolicy
    UPLOAD_DIR = "#{Rails.root}/#{Setting[:attachment_path]}"
    def upload(filename, file, mimetype, message)
      filepath = "#{UPLOAD_DIR}/#{self.class.unique_id}-#{filename}"
      File.open(filepath, 'wb') do|io|
        io.write file.read
      end

      [ self.class.url_for_localfile(filepath), filepath ]
    end

    def self.url_for_localfile(path)
      if path =~ %r!.*/public(/.+)! then
        (Rails.configuration.relative_url_root || "") + $1
      end
    end

    def self.unique_id
      UUIDTools::UUID.random_create.to_s
    end
  end

  register('local' , LocalStorePolicy)
end
