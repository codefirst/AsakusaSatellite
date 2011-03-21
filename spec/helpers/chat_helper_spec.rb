# -*- coding: utf-8-emacs -*-
 require File.dirname(__FILE__) + '/../spec_helper'

describe ChatHelper do
  before {
    @room = Room.new
    @room.save

    @message = mock "message"
    @message.stub(:body=)
    Message.stub(:new => @message)
    Message.stub(:find => @message)
  }

  context "成功時" do
    before do
      @message.stub(:save => true, :destroy => true)
      @publish = helper.should_receive :publish_message
    end

    share_examples_for 'publish message' do
      subject { @publish }
      it { should be_expected_messages_received }
    end

    share_examples_for 'not publish message' do
      subject { @publish }
      it { should be_expected_messages_received }
    end

    describe "作成" do
      before { helper.create_message(@room.id, 'message') }
      it_should_behave_like 'publish message'
    end

    describe "更新" do
      before { helper.update_message(1, 'message') }
      it_should_behave_like 'publish message'
    end

    describe "削除" do
      before { helper.delete_message(1) }
      it_should_behave_like 'publish message'
    end
  end

  context "失敗時" do
    before do
      @message.stub(:save => false, :destroy => false)
      @publish = helper.should_not_receive :publish_message
    end

    describe "作成" do
      before { helper.create_message(@room.id, 'message') }
      it_should_behave_like 'not publish message'
    end

    describe "更新" do
      before { helper.update_message(1, 'message') }
      it_should_behave_like 'not publish message'
    end

    describe "削除" do
      before { helper.delete_message(1) }
      it_should_behave_like 'not publish message'
    end
  end
end
