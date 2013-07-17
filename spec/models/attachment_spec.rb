# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Attachment do
  before do
    @attachment = Attachment.new(:disk_filename => '/public/file.png',
                                 :filename => 'file.png',
                                 :mimetype => 'image/png')

    @message = Message.new
    @message.attachments = [ @attachment ]
    @message.save!
  end

  describe "to_hash" do
    subject { @attachment.to_hash }
    its([:disk_filename]) { should == "file.png"  }
    its([:filename])      { should == "file.png"  }
    its([:content_type])  { should == "image/png" }
    its([:url])  { should == "/file.png" }
  end

  describe "create_and_save_file" do
    before {
      Attachment::LocalStorePolicy.stub(:unique_id){ "hogehoge" }
    }

    subject {
      Attachment.create_and_save_file(File.basename(__FILE__),
                                      StringIO.new(""),
                                      'text/plain',
                                      Message.new)
    }
    its(:filename) { should == File.basename(__FILE__) }
    it { File.should be_exists(subject.disk_filename) }

    its(:disk_filename) { should match(/hogehoge/) }
  end

  it do
    message = Message.new
    expect {
      Attachment.create_and_save_file(File.basename(__FILE__),
                                      StringIO.new(""),
                                      'text/plain',
                                      message)
    }.to change { message.attachments.size }.by(1)
  end
end
