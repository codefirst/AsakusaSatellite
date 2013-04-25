# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  before do
    cleanup_db

    @room = Room.new(:title => 'test room').tap{|x| x.save! }
    @user = User.new(:name => 'test user', :screen_name => 'test').tap{|x| x.save! }

    @other_room = Room.new(:title => "dummy_room")
    @other_room.save!

    @messages = (0..10).map do|i|
      Message.new(:body => "dummy", :user => @user, :room => @other_room).save!
      Message.new(:body => "body of message #{i}",
                    :user => @user,
                    :room => @room).tap{|m| m.save! }
    end

    @message = @messages[5]

    @private_room = Room.new(:title => "dummy_room", :is_public => false)
    @private_room.save!

    @private_message = Message.new(:body => "private message", :user => @user, :room => @private_room)
    @private_message.save!
  end

  subject { @message }
  its(:body) { should == @message.body }
  its(:room) { should == @room }

  describe "room" do
    subject { @message.room }
    its(:title) { should == @room.title }
  end

  describe "hash" do
    before do
      AsakusaSatellite::Filter.stub(:process){|message, room| "filtered:#{message.body}" }
    end

    subject { @message.to_hash }
    its(['name']) { should == @message.user.name }
    its(['profile_image_url']) { should == @message.user.profile_image_url }
    its(['body']) { should == @message.body }
    its(['attachment']) { should be_empty }
    it { subject['id'].should == @message.id }
    its(['screen_name']) { should == @message.user.screen_name }
    its(['created_at']) { should == @message.created_at.to_s }
    its(['html_body']) { should == "filtered:#{@message.body}" }
  end

  it { should have(1).prev(1) }
  it { should have(2).prev(2) }
  it { should have(1).next(1) }
  it { should have(2).next(2) }

  describe "prev" do
    context "with 2" do
      subject { @message.prev 2 }
      it { should == [ @messages[3], @messages[4] ] }
    end
    context "with 0" do
      subject { @message.prev 0 }
      it { should == [] }
    end
  end

  describe "next" do
    context "with 2" do
      subject { @message.next 2 }
      it { should == [ @messages[6], @messages[7] ] }
    end
    context "with 0" do
      subject { @message.next 0 }
      it { should == [] }
    end
  end

  share_examples_for 'メッセージ有'  do
    subject { @result.first }
    its([:room]) { should == @room }
    its([:messages]) { should have(11).records }
  end

  share_examples_for 'メッセージ無'  do
    subject { @result.first }
    its([:room]) { should == @room }
    its([:messages]) { should have(0).records }
  end

  describe "find_by_text" do
    context "部屋指定なし" do
      context "一致する場合" do
        before { @result = Message.find_by_text(:text => "body of message") }
        subject { @result }
        it { should have(2).item }

        it_should_behave_like 'メッセージ有'
      end

      context "一致しない場合" do
        before { @result = Message.find_by_text(:text => "__") }
        subject { @result }
        it { should have(2).item }

        it_should_behave_like 'メッセージ無'
      end

      context "private で所属していない部屋" do
        before { @result = Message.find_by_text(:text => "private message") }
        subject { @result }
        it { should have(2).item }
        it_should_behave_like 'メッセージ無'
      end

    end

    context "部屋指定あり" do
      context "単一指定" do
        before { @result = Message.find_by_text(:text => "body of message", :rooms => [ @room ]) }
        subject { @result }
        it { should have(1).item }
        it_should_behave_like 'メッセージ有'
      end

      context "複数指定" do
        before { @result = Message.find_by_text(:text => "body of message", :rooms => [ @room, @other_room ]) }
        subject { @result }
        it { should have(2).item }
        it_should_behave_like 'メッセージ有'
      end
    end
  end

  describe "メッセージの保存・破棄に失敗する" do
    before {
      @stub_message = mock "message"
      @stub_message.stub(:body= => nil)
      Message.stub(:new => @stub_message)
    }

    context "メッセージ作成" do
      before { @stub_message.should_receive(:save).and_return(false) }
      it { Message.create_message(@user, @room, "new message") }
    end

    context "メッセージ更新" do
      before {
        @stub_message.should_receive(:save).and_return(false)
        Message.should_receive(:with_own_message).and_yield(@stub_message)
      }
      it { Message.update_message(@user, "0", "modified message") }
    end

    context "メッセージ破棄" do
      before {
        @stub_message.should_receive(:destroy).and_return(false)
        Message.should_receive(:with_own_message).and_yield(@stub_message)
      }
      it { Message.delete_message(@user, "0") }
    end
  end

  describe "添付ファイル" do
    before {
      Setting.should_receive(:[]).with(:attachment_max_size).and_return("1")
    }

    context "添付ファイルを保存する" do
      before {
        file = mock "file"
        file.stub(:size => 10.kilobyte)
        @params = mock "param"
        @params.stub(:[] => file, :filename => "test.txt", :mimetype => "text/plain", :file => nil)
      }
      it {
        Attachment.should_receive(:create_and_save_file)
        Message.create_attach(@user, @room, @params)
      }
    end

    context "添付ファイルのサイズが容量制限を上回る" do
      before {
        file = mock "file"
        file.stub(:size => 100.megabyte)
        @params = mock "param"
        @params.stub(:[] => file)
      }
      it {
        Message.should_not_receive(:new)
        Message.create_attach(@user, @room, @params)
      }
    end
  end
end
