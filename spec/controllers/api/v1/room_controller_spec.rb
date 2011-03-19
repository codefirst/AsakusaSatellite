# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::RoomController do
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
