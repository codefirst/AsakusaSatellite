# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::RoomController do
  describe "部屋取得API" do
    before do
      user = User.new(:name => 'test', :screen_name => 'test user', :profile_image_url => 'test')
      user.save!

      @room = Room.new(:title=>"test room", :user => user)
      @room.save!

      @m1 = Message.new(:body => 'm1', :user => user, :created_at => Time.now, :room => @room)
      @m2 = Message.new(:body => 'm2', :user => user, :created_at => Time.now, :room => @room)
      @m3 = Message.new(:body => 'm3', :user => user, :created_at => Time.now, :room => @room)

      @m1.save!
      @m2.save!
      @m3.save!
    end

    it "取得した発言には:viewが含まれる" do
      get :show, :id => @room.id, :format => 'json'
      response.body.should have_json("/view")
      assigns[:messages].size.should == 3
    end

    it "until_idをわたせば、それ以前のメッセージが取得できる" do
      get :show, :id => @room.id, :until_id => @m2.id , :format => 'json'
      assigns[:messages].size.should == 2
    end

    it "countをわたせば、件数が指定できる" do
      get :show, :id => @room.id, :until_id => @m2.id, :count => 1 , :format => 'json'
      assigns[:messages].size.should == 1
    end
  end

  describe "部屋一覧取得API" do
    it "取得する" do
      user = User.new(:spell => 'spell')
      user.save
      Room.select.each { |r| r.delete }
      room = Room.new(:title => 'title', :user => user)
      room.save
      get :list, :format => 'json'
      response.body.should have_json("/name[1][text() = 'title']")
    end

  end

  describe "部屋作成API" do
    it "部屋を作成する" do
      user = User.new(:spell => 'spell')
      user.save
      post :create, :name => 'room name', :api_key => user.spell, :format => 'json'
      response.body.should have_json("/status[text() = 'ok']")
    end

    it "復活の呪文を間違えると作成できない" do
      User.select.each { |r| r.delete }
      post :create, :name => 'room name', :api_key => 'spell', :format => 'json'
      response.body.should have_json("/status[text() = 'error']")
    end
  end

  describe "部屋更新API" do
    it "部屋名を更新する" do
      user = User.new(:spell => 'spell')
      user.save
      room = Room.new(:title => 'title', :user => user)
      room.save
      new_name = 'room name'
      post :update, :id => room.id, :name => new_name, :api_key => user.spell, :format => 'json'
      Room.find(room.id).title.should == new_name
      response.body.should have_json("/status[text() = 'ok']")
    end

    it "復活の呪文を間違えると更新できない" do
      User.select.each { |r| r.delete }
      user = User.new(:spell => 'spell')
      user.save
      room = Room.new(:title => 'title', :user => user)
      room.save
      post :update, :id => room.id, :name => 'room name', :api_key => '', :format => 'json'
      Room.find(room.id).title.should == 'title'
      response.body.should have_json("/status[text() = 'error']")
    end
  end

  describe "部屋削除API" do
    it "部屋名を更新する" do
      user = User.new(:spell => 'spell')
      user.save
      room = Room.new(:title => 'title', :user => user)
      room.save
      post :destroy, :id => room.id, :api_key => user.spell, :format => 'json'
      Room.find(room.id).deleted.should be_true
      response.body.should have_json("/status[text() = 'ok']")
    end

    it "復活の呪文を間違えると更新できない" do
      User.select.each { |r| r.delete }
      user = User.new(:spell => 'spell')
      user.save
      room = Room.new(:title => 'title', :user => user)
      room.save
      post :destroy, :id => room.id, :api_key => '', :format => 'json'
      Room.find(room.id).should_not be_false
      response.body.should have_json("/status[text() = 'error']")
    end
  end
end
