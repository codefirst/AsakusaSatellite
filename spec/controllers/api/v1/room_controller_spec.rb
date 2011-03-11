# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::RoomController do
  describe "部屋取得API" do
    it "取得した発言には:viewが含まれる" do
      user = mock_model(User)
      user.stub!(:screen_name).and_return('user')
      user.stub!(:name).and_return('name')
      image_url = 'http://example.com/hoge.png'
      user.stub!(:profile_image_url).and_return(image_url)

      m1 = Message.new(:body => 'm1', :user => user, :created_at => Time.now)
      m2 = Message.new(:body => 'm2', :user => user, :created_at => Time.now)
      m3 = Message.new(:body => 'm3', :user => user, :created_at => Time.now)
      room = Room.new
      Message.stub!(:select).and_return([m1, m2, m3])
      Attachment.stub!(:select).and_return(nil)
      get :show, :id => room.id, :format => 'json'
      response.body.should have_json("/view")
    end

    it "since_dateパラメータを渡すと指定日以降のメッセージを返す" do
      user = User.new(:name => 'test', :screen_name => 'test user', :profile_image_url => 'test')
      user.save
      room = Room.new(:title => 'title', :user => user)
      room.save
      message1 = Message.new(:user => user, :room => room,
        :body => 'message1', :created_at => Date.new(2011, 1, 1).beginning_of_day.to_i)
      message1.save
      message2 = Message.new(:user => user, :room => room,
        :body => 'message2', :created_at => Date.new(2011, 1, 2).beginning_of_day.to_i)
      message2.save
      get :show, :id => room.id, :since_date => Date.new(2011, 1, 2).strftime("%Y-%m-%d"), :format => 'json'
      assigns[:messages].records.size.should == 2
      response.body.should have_json("/view")
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
