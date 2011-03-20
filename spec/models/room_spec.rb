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
      Room.select.each { |r| r.delete }
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

  before {
    @user = User.new
    @room = Room.new(:title => 'room1', :user => @user, :updated_at => Time.now)
  }
  describe "to_json" do
    subject { @room.to_json }
    its([:name]) { should == "room1" }
    its([:user])  { should == @user.to_json }
    its([:updated_at]) { should == @room.updated_at }
  end

  describe "yaml field" do
    before  { @room.yaml = { 'foo' => 'baz' } }
    subject { @room.yaml }
    its(['foo']) { should == 'baz' }
    it{ should have(1).items }
  end
end
