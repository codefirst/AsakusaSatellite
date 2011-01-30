require 'uuidtools'
class Attachment < ActiveGroonga::Base
  UPLOAD_DIR = "#{RAILS_ROOT}/public/upload"
  def to_hash
    {
      :disk_filename => File.basename(self.disk_filename),
      :filename => self.filename,
      :content_type => self.content_type
    }
  end

  def self.create_and_save_file(filename, file, message)
    disk_filename = UUIDTools::UUID.random_create.to_s + "-" + filename
    open("#{UPLOAD_DIR}/#{disk_filename}", "wb") do |f|
      f.write(file.read)
    end
    attachement = Attachment.new(:filename => filename,
                                 :disk_filename => "#{UPLOAD_DIR}/#{disk_filename}", 
                                 :message => message)
    attachement.save
    logger.info "hoge"
    attachment
  end
end
