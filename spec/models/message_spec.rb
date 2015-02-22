# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  before do
    cleanup_db

    @room = Room.create!(:title => 'test room')
    @user = User.create!(:name => 'test user', :screen_name => 'test')

    @other_room = Room.create!(:title => "dummy_room")

    @messages = (0..10).map do|i|
      Message.create!(:body => "dummy", :user => @user, :room => @other_room)
      Message.create!(:body => "body of message #{i}",
                    :user => @user,
                    :room => @room)
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

  describe "strip body" do
    subject { Message.create!(:body => " abc ") }
    its(:body) { should == "abc" }
  end

  describe "hash" do
    before do
      allow(AsakusaSatellite::Filter).to receive(:process){|message, room| "filtered:#{message.body}" }
    end

    subject { @message.to_hash }
    its(['name']) { should == @message.user.name }
    its(['profile_image_url']) { should == @message.user.profile_image_url }
    its(['body']) { should == @message.body }
    its(['attachment']) { should be_empty }
    it { expect(subject['id']).to eq @message.id }
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

  describe "prev_id" do
    context "has prev" do
      subject { @messages[5].prev_id }
      it { should == @messages[4].id }
    end
    context "not has prev" do
      subject { @messages[0].prev_id }
      it { should be_nil }
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

  shared_examples_for 'メッセージ有'  do
    subject { @result.first }
    its([:room]) { should == @room }
    its([:messages]) { should have(11).records }
  end

  shared_examples_for 'メッセージ無'  do
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

    context "with Regexp meta characters" do
      context "for (" do
        before { @result = Message.find_by_text(:text => "(") }
        subject { @result }
        it { should have(2).item }
        it_should_behave_like 'メッセージ無'
      end
    end
  end

  describe "メッセージの保存・破棄に失敗する" do
    before {
      @stub_message = double "message"
      allow(@stub_message).to receive_messages(:body= => nil)
      allow(Message).to receive_messages(:new => @stub_message)
    }

    context "メッセージ作成" do
      before { expect(@stub_message).to receive(:save).and_return(false) }
      it { Message.make(@user, @room, "new message") }
    end

    context "メッセージ更新" do
      before {
        expect(Message).to receive(:where).and_return([@stub_message])
        expect(Message).to receive(:===).and_return(true)
        expect(@stub_message).to receive(:save).and_return(false)
      }
      it { Message.update_body(@user, "0", "modified message") }
    end

    context "メッセージ破棄" do
      before {
        expect(Message).to receive(:where).and_return([@stub_message])
        expect(Message).to receive(:===).and_return(true)
        expect(@stub_message).to receive(:destroy).and_return(false)
      }
      it { Message.delete(@user, "0") }
    end
  end

  describe "添付ファイル" do
    before {
      expect(Setting).to receive(:[]).with(:attachment_max_size).and_return("1")
      @stub_message = Message.make(@user, @room, nil, true)
      @file = double "file"
      allow(@file).to receive_messages(:size => 10.kilobyte, :original_filename => "file1.jpg", :content_type => "image/jpeg")
      @large_file = double "large file"
      allow(@large_file).to receive_messages(:size => 10.megabyte)
    }

    context "添付ファイルを保存する" do
      it {
        expect(Attachment).to receive(:create_and_save_file)
        @stub_message.attach(@file)
      }
    end

    context "添付ファイルのサイズが容量制限を上回る" do
      it {
        expect(Attachment).not_to receive(:create_and_save_file)
        @stub_message.attach(@large_file)
      }
    end
  end
end
