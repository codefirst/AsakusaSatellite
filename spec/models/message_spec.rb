# -*- coding: utf-8-emacs -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  before do
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
      I18n.stub(:l){|s| "i18n:#{s}" }
      AsakusaSatellite::Filter.stub(:process){|s| "filtered:#{s}" }
    end

    subject { @message.to_hash }
    its(['name']) { should == @message.user.name }
    its(['profile_image_url']) { should == @message.user.profile_image_url }
    its(['body']) { should == @message.body }
    its(['attachment']) { should == nil }
    it { subject['id'].should == @message.id }
    its(['screen_name']) { should == @message.user.screen_name }
    its(['created_at']) { should == "i18n:#{@message.created_at}" }
    its(['html_body']) { should == "filtered:#{@message.body}" }
  end

  it { should have(1).prev(1) }
  it { should have(2).prev(2) }
  it { should have(1).next(1) }
  it { should have(2).next(2) }

  describe "prev" do
    subject { @message.prev 2 }
    it { should == [ @messages[3], @messages[4] ] }
  end

  describe "next" do
    subject { @message.next 2 }
    it { should == [ @messages[6], @messages[7] ] }
  end
end
