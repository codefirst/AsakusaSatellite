# -*- coding: utf-8 -*-
require 'spec_helper'

describe Member do
  before do
    @room1 = Room.new(:title => 'room1',
                      :user => nil,
                      :updated_at => Time.now).tap{|x| x.save! }
    @room2 = Room.new(:title => 'room2',
                      :user => nil,
                      :updated_at => Time.now).tap{|x| x.save! }
    @user1 = User.new(:name => 'test user', :screen_name => 'user1').tap{|x| x.save! }
    @user2 = User.new(:name => 'test user', :screen_name => 'user2').tap{|x| x.save! }
  end

  it "何もしなければ空" do
    @room1.members.should == []
    @room2.members.should == []
  end

  it "参加者一覧がとれる" do

    @room1.join @user1
    @room1.members.should == [ @user1 ]
    @room2.members.should == []

    @user1.rooms.should == [ @room1 ]
    @user2.rooms.should == []
  end

  it "重複はない" do
    @room1.join @user1
    @room1.join @user1
    @room1.join @user1

    @room1.members.should == [ @user1 ]
    @room2.members.should == []

    @user1.rooms.should == [ @room1 ]
    @user2.rooms.should == []
  end

  it "複数人参加できる" do
    @room1.join @user1
    @room1.join @user2

    @room1.members.should == [ @user1, @user2 ]
    @room2.members.should == []

    @user1.rooms.should == [ @room1 ]
    @user2.rooms.should == [ @room1 ]
  end

  it "複数の部屋に参加できる" do
    @room1.join @user1
    @room2.join @user1

    @room1.members.should == [ @user1 ]
    @room2.members.should == [ @user1 ]

    @user1.rooms.should == [ @room1, @room2 ]
    @user2.rooms.should == []
  end

  it "退室できる" do
    @room1.join @user1
    @room1.members.should == [ @user1 ]

    @room1.leave @user1
    @room1.members.should == []
    @user1.rooms.should == []
  end
end
