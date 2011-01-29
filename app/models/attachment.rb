class Attachment < ActiveGroonga::Base
  def encode_json(_)
    {
      :disk_filename => File.basename(self.disk_filename),
      :filename => self.filename,
      :content_type => content_type
    }.to_json
  end
end

