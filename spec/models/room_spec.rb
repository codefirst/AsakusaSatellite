# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Room do
  share_examples_for '妥当でない部屋'  do
    its(:save) { should be_false }
    its(:validate) { should be_false }
  end

  context "タイトルが空" do
    subject{ Room.new(:title => '') }
    it_should_behave_like '妥当でない部屋'
  end
  context "タイトルがnil" do
    subject{ Room.new(:title => nil) }
    it_should_behave_like '妥当でない部屋'
  end
  context "初期状態" do
    subject { Room.new }
    it_should_behave_like '妥当でない部屋'
  end

  describe "all_live" do
    before(:each) do
      Room.delete_all
    end

    context "rooms が空" do
      subject { Room.all_live }
      it { should have(0).records }
    end

    context "rooms が2個" do
      before do
        Room.new(:title => 'room1', :user => nil, :updated_at => Time.now).save
        Room.new(:title => 'room2', :user => nil, :updated_at => Time.now).save
      end

      subject { Room.all_live }
      it { should have(2).records }
    end

    context "duplicated nickname rooms" do
      before do
        Room.delete_all(:nickname => 'nickname')
        Room.new(:title => 'room1', :nickname => 'nickname').save
        @room = Room.new(:title => 'room2', :nickname => 'nickname')
        @room.save
      end
      subject { @room.errors }
      it { should have(1).items }
    end

    context "rooms が2個かつ1個削除されている" do
      before do
        Room.new(:title => 'room1', :user => nil, :updated_at => Time.now).save!
        room = Room.new(:title => 'room2', :user => nil, :updated_at => Time.now)
        room.deleted = true
        room.save!
      end

      subject { Room.all_live }
      it { should have(1).records }
    end
  end

  context "to_param" do
    context "with nickname" do
      before do
        Room.delete_all(:nickname => 'nickname')
        @room = Room.new(:title => 'room', :nickname => 'nickname')
        @room.save
      end
      subject { @room }
      its(:to_param) { should == 'nickname' }
    end
    context "without nickname" do
      before do
        Room.delete_all(:nickname => 'nickname')
        @room = Room.new(:title => 'room', :nickname => '')
        @room.save
      end
      subject { @room }
      its(:to_param) { should == @room.id.to_s }
    end
  end

  before {
    @user = User.new
    @room = Room.new(:title => 'room1', :user => @user, :nickname => 'nickname', :updated_at => Time.now)
  }
  describe "to_json" do
    subject { @room.to_json }
    its([:name]) { should == "room1" }
    its([:user])  { should == @user.to_json }
    its([:nickname])  { should == "nickname" }
    its([:updated_at]) { should == @room.updated_at.to_s }
  end

  describe "yaml field" do
    before  { @room.yaml = { 'foo' => 'baz' } }
    subject { @room.yaml }
    its(['foo']) { should == 'baz' }
    it{ should have(1).items }
  end

  describe "messages" do
    before do
      @messages = (0..10).map do|i|
        Message.new(:body => "body of message #{i}",
                    :room => @room).tap{|m| m.save! }
      end
    end
    describe "messages" do
      subject { @room.messages(5) }
      it { should have(5).items }
      it { should == @messages[6..-1] }
    end

    describe "messages_between" do
      subject { between = @room.messages_between(@messages[3].id, @messages[5].id, 2) }
      it { should == [@messages[3], @messages[4]] }
    end
  end

  describe "owner and members" do
    before do
      @user = User.create
      @member = User.create
      @room = Room.create(:title => 'room private', :user => @user, :is_public => false)
      @room.members << @member
    end

    context "user" do
      subject { @room.user }
      it { should == @user }
    end

    context "members" do
      subject { @room.members.to_set }
      it { should == [@member].to_set }
    end

    context "owner_and_members" do
      context "exist members" do
        subject { @room.owner_and_members.to_set }
        it { should == [@user, @member].to_set }
      end

      context "no members" do
        before do
          @room = Room.create(:title => 'room private', :user => @user, :is_public => false)
        end

        subject { @room.owner_and_members.to_set }
        it { should == [@user].to_set }
      end
    end
  end

  describe "accessible?" do
    context "publicな部屋" do
      before {
        @room = Room.create(:title => 'room public', :user => @user, :is_public => true)
      }

      subject { @room.accessible?(@user) }
      it { should be_true }
    end

    context "privateな部屋" do
      before do
        @member = User.create
        @other = User.create
        @room = Room.create(:title => 'room public', :user => @user, :is_public => false)
        @room.members << @member
      end

      context "owner" do
        subject { @room.accessible? @user }
        it { should be_true }
      end

      context "member" do
        subject { @room.accessible? @member }
        it { should be_true }
      end

      context "その他" do
        subject { @room.accessible? @other }
        it { should be_false }
      end
    end
  end
end
