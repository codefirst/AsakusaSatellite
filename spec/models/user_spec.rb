# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before  do
    @room1 = Room.new(:title => 'testroom1').tap{|r| r.save! }
    @room2 = Room.new(:title => 'testroom2').tap{|r| r.save! }
    @user = User.new(:name => 'test user',
                     :screen_name => 'test',
                     :email => 'user@example.com',
                     :profile_image_url => 'http://example.com/profile.png',
                     :user_profiles => [UserProfile.new(:room_id => @room1._id,
                                                        :name => "name for room1",
                                                        :profile_image_url => "http://example.com/pic.jpg")],
                     :spell => 'spell')
  end

  subject { @user }

  it { should be_respond_to :name }
  it { should be_respond_to :screen_name }
  it { should be_respond_to :email }
  it { should be_respond_to :profile_image_url }
  it { should be_respond_to :spell }
  it { should be_respond_to :devices }
  describe "to_json" do
    subject { @user.to_json }
    its([:name]) { should == "test user" }
    its([:screen_name]) { should == "test" }
    its([:profile_image_url]) { should == "http://example.com/profile.png" }
    it { should_not have_key(:spell) }
    it { should_not have_key(:email) }
  end
  describe "register_spell" do
    before {
      @user.register_spell
    }
    subject { @user.spell }
    its (:size) { should <= 30 }
    its (:size) { should >= 20 }
    it { should =~ /([0-9a-zA-Z])+/ }
  end

  describe "profile_for" do
    describe "指定された部屋のプロファイルを返す" do
      subject { @user.profile_for(@room1._id) }
      its([:name]) { should == "name for room1" }
      its([:profile_image_url]) { should == "http://example.com/pic.jpg" }
    end

    describe "指定された部屋のプロファイルがなければデフォルト値を返す" do
      subject { @user.profile_for(@room2._id) }
      its([:name]) { should == "test user" }
      its([:profile_image_url]) { should == "http://example.com/profile.png" }
    end
  end
end
