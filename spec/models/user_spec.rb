# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before  do
    @room1 = Room.create!(:title => 'testroom1')
    @room2 = Room.create!(:title => 'testroom2')
    @room3 = Room.create!(:title => 'testroom3')
    @user = User.create(:name => 'test user',
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

  describe "find_or_create_profile_for" do
    describe "プロファイルが存在しない場合は新規作成する" do
      before { @user.find_or_create_profile_for(@room3._id) }
      subject { @user.profile_for(@room3._id) }
      it { should_not be nil }
    end

    describe "新規作成したプロファイルはデフォルトと同じ" do
      subject { @user.profile_for(@room3._id) }
      its([:name]) { should be @user.name }
      its([:profile_image_url]) { should be @user.profile_image_url }
    end

    describe "プロファイルが存在する場合は既存のプロファイルを返す" do
      before { @profile_for_room1 = @user.profile_for(@room1._id) }
      subject { @user.find_or_create_profile_for(@room1._id) }
      its([:name]) { should be @profile_for_room1[:name] }
      its([:profile_image_url]) { should be @profile_for_room1[:profile_image_url] }
    end
  end

  describe "update_profile_for" do
    describe "指定された部屋のプロファイルを変更する" do
      before { @user.update_profile_for(@room3._id, "name for room3", "http://example.com/pic3.jpg") }
      subject { @user.profile_for(@room3._id) }
      its([:name]) { should eq "name for room3" }
      its([:profile_image_url]) { should eq "http://example.com/pic3.jpg" }
    end
  end

  describe "delete_profile_for" do
    describe "指定された部屋のプロファイルを削除する" do
      before { @user.delete_profile_for(@room3._id) }
      subject { @user.user_profiles.where(:room_id => @room3._id).to_a }
      it { should eq [] }
    end

    describe "指定された部屋にプロファイルがない場合はなにもしない" do
      before { @user.delete_profile_for(@room3._id) }
      subject { @user.user_profiles.where(:room_id => @room3._id).to_a }
      it { should eq [] }
    end
  end
end
