# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::MessageController do
  describe "発言取得API" do
    it "1件取得すると :name, :body, :profile_image_url, :view が取得できる" do
      image_url = 'http://example.com/hoge.png'
      user = mock_model(User)
      user.stub!(:screen_name).and_return('user')
      user.stub!(:name).and_return('name')
      user.stub!(:profile_image_url).and_return(image_url)
      message = Message.new(:body => 'hoge', :user => user, :created_at => Time.now)
      Message.stub!(:find).with(message.id).and_return(message)
      Attachment.stub!(:select).and_return(nil)
      get :show, :id => message.id, :format => 'json'
      response.body.should have_json("/screen_name[text() = 'user']")
      response.body.should have_json("/body[text() = 'hoge']")
      response.body.should have_json("/view")
      response.body.should have_json("/profile_image_url[text() = '#{image_url}']")

      # permlinkがAPIのほうを差していない
      response.body.should have_json("/view[not(contains(text(), 'api'))]")
    end

    it "1件postする" do
      session[:current_user_id] = 1
      ChatHelper.stub!(:publish_message).and_return(true)
      pending('websocketにつなぎに行くのを切る方法が分からない')
      post :create, :room_id => 1, :message => 'message'
      response.body.should have_json("/profile_image_url[text() = '11']")
    end
  end

  describe "メッセージ作成API" do
    it "ログインユーザは作成可能" do
      user = User.new
      user.save
      session[:current_user_id] = user.id
      room = Room.new(:title => 'test')
      room.save
      post :create, :room_id => room.id, :message => 'message'
      response.body.should have_json("/status[text() = 'ok']")
    end
    it "非ログインユーザは作成できない" do
      session[:current_user_id] = nil 
      room = Room.new(:title => 'test')
      room.save
      post :create, :room_id => room.id, :message => 'message'
      response.body.should have_json("/status[text() = 'error']")
    end
    it "復活の呪文付きの場合は該当ユーザとして作成可能" do
      session[:current_user_id] = nil 
      user = User.new(:name => 'user', :screen_name => 'user name', :spell => 'aaa')
      user.save
      room = Room.new(:title => 'test')
      room.save
      post :create, :room_id => room.id, :message => 'message', :api_key => user.spell
      response.body.should have_json("/status[text() = 'ok']")

    end
  end

  describe "メッセージ更新API" do
    it "ログインユーザは更新可能" do
      user = User.new
      user.save
      session[:current_user_id] = user.id
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :update, :id => message.id, :message => 'message'
      response.body.should have_json("/status[text() = 'ok']")
    end
    it "復活の呪文付きであれば該当ユーザで更新可能" do
      user = User.new(:name => 'user', :screen_name => 'user name', :spell => 'aaa')
      user.save
      session[:current_user_id] = nil 
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :update, :id => message.id, :message => 'message', :api_key => user.spell
      response.body.should have_json("/status[text() = 'ok']")
    end
    it "他人が作成したメッセージ以外は更新できない" do
      user = User.new(:name => 'user', :screen_name => 'user name', :spell => 'aaa')
      user.save
      other_user = User.new
      other_user.save
      session[:current_user_id] = nil 
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => other_user, :room => room)
      message.save
      post :update, :id => message.id, :message => 'message', :api_key => user.spell
      response.body.should have_json("/status[text() = 'error']")
    end
    it "非ログインユーザは更新できない" do
      user = User.new
      user.save
      session[:current_user_id] = nil 
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :update, :id => message.id, :message => 'message'
      response.body.should have_json("/status[text() = 'error']")
    end
  end

  describe "メッセージ削除API" do
    it "ログインユーザは削除可能" do
      user = User.new
      user.save
      session[:current_user_id] = user.id
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :destroy, :id => message.id
      response.body.should have_json("/status[text() = 'ok']")
    end
    it "復活の呪文付きの場合は該当ユーザで削除可能" do
      user = User.new(:name => 'user', :screen_name => 'user name', :spell => 'aaa')
      user.save
      session[:current_user_id] = nil
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :destroy, :id => message.id, :api_key => user.spell
      response.body.should have_json("/status[text() = 'ok']")

    end
    it "他人が作成したメッセージ以外は削除できない" do
      user = User.new(:name => 'user', :screen_name => 'user name', :spell => 'aaa')
      user.save
      other_user = User.new
      other_user.save
      session[:current_user_id] = nil 
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => other_user, :room => room)
      message.save
      post :destroy, :id => message.id, :api_key => user.spell
      response.body.should have_json("/status[text() = 'error']")
    end

    it "非ログインユーザは削除できない" do
      user = User.new
      user.save
      session[:current_user_id] = nil 
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :destroy, :id => message.id
      response.body.should have_json("/status[text() = 'error']")
    end
  end

end
