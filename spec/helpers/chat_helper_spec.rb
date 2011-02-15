require File.dirname(__FILE__) + '/../spec_helper'

describe ChatHelper do
  context "メッセージを作成する" do
    it "メッセージの保存に成功する" do
      room = Room.new
      room.save
      helper.create_message(room.id, 'message').body.should == 'message'
    end
    it "メッセージの保存に失敗する" do
      message = mock
      message.stub(:save).and_return(false)
      Message.stub(:new).and_return(message)    
      room = Room.new
      room.save
      helper.create_message(room.id, 'message').should be_false
    end
  end
  context "メッセージを更新する" do
    it "成功する" do
      message = Message.new(:body => 'init')
      message.save
      helper.update_message(message.id, 'modified').should be_true
      Message.find(message.id).body.should == 'modified'
    end
    it "失敗する" do
      message = mock
      message.stub(:save).and_return(false)
      message.stub(:body=)
      Message.stub(:find).and_return(message)
      helper.update_message(0, 'modified').should be_false
    end
  end
  context "メッセージを削除する" do
    it "成功する" do
      message = Message.new(:body => 'init')
      message.save
      helper.delete_message(message.id).should be_true
      Message.find(message.id).should be_nil
    end
    it "失敗する" do
      message = mock
      message.stub(:destroy).and_return(false)
      Message.stub(:find).and_return(message)
      helper.delete_message(0).should be_false
    end
  end
end
