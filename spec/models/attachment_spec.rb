require File.dirname(__FILE__) + '/../spec_helper'

describe Attachment do
  it "Hashに変換できる" do
    attachment = Attachment.new(
      :disk_filename => '/tmp/file.png',
      :filename => 'file.png',
      :mimetype => 'image/png'
    ) 
    attachment.to_hash.should == {
      :disk_filename => 'file.png',
      :filename => 'file.png',
      :content_type => 'image/png'
    }
  end

  it "ファイルを保存するとレコードが1行増える" do
    message = Message.new
    open(__FILE__) do |file|
      lambda {
        attachment = Attachment.create_and_save_file(File.basename(__FILE__), file, 'text/plain', message)   
        attachment.filename.should == File.basename(__FILE__)
        File.exists?(attachment.disk_filename).should be_true
      }.should change(Attachment.all.records, :size).by(1)
    end
  end
end
