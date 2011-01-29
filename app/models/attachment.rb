class Attachment < ActiveGroonga::Base
  def to_hash
    {
      :disk_filename => File.basename(self.disk_filename),
      :filename => self.filename,
      :content_type => self.content_type
    }
  end
end
