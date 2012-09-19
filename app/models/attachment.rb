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
      response = JSON.parse(post_multipart(uri, file).body)
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

  def self.post_multipart(uri, file, content_type=file.content_type, boundary="A300x")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start do
      request = Net::HTTP::Post.new(uri.path + "?" + (uri.query || ""))
      request["user-agent"] = "Ruby/#{RUBY_VERSION} MyHttpClient"
      request.set_content_type "multipart/form-data; boundary=#{boundary}"
      body = "--#{boundary}\r\n"
      body += "Content-Disposition: form-data; name=\"upload[file]\"; filename=\"#{URI.encode(file.original_filename)}\"\r\n"
      body += "Content-Type: #{content_type}\r\n"
      body += "\r\n"
      body += "#{file.read}\r\n"
      body += "\r\n"
      body += "--#{boundary}--\r\n"
      request.body = body
      http.request request
    end
  end

end
