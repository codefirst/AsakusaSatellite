# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Attachment do
  before do
    @attachment = Attachment.new(:disk_filename => '/tmp/file.png',
                                 :filename => 'file.png',
                                 :mimetype => 'image/png')
    @attachment.save!
  end

  describe "to_hash" do
    subject { @attachment.to_hash }
    its([:disk_filename]) { should == "file.png"  }
    its([:filename])      { should == "file.png"  }
    its([:content_type])  { should == "image/png" }
  end

  describe "create_and_save_file" do
    before {
      Attachment.stub(:unique_id){ "hogehoge" }
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
    expect {
      Attachment.create_and_save_file(File.basename(__FILE__),
                                      StringIO.new(""),
                                      'text/plain',
                                      Message.new)
    }.to change { Attachment.all.size }.by(1)
  end
end
