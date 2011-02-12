require File.dirname(__FILE__) + '/../spec_helper'

describe ChatHelper do
  it "メッセージを作成する" do
    room = Room.new
    room.save
    helper.create_message(room.id, 'message').body.should == 'message'
  end
  it "メッセージを更新する" do
    message = Message.new(:body => 'init')
    message.save
    helper.update_message(message.id, 'modified').should be_true
    Message.find(message.id).body.should == 'modified'
  end
  it "メッセージを削除する" do
    message = Message.new(:body => 'init')
    message.save
    helper.delete_message(message.id).should be_true
    Message.find(message.id).should be_nil
  end
end
