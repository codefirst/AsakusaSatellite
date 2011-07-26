# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::LoginController do
  describe "ログインAPI" do
    it "ユーザを取得できれば ok を返す" do
      user = User.new(:screen_name => 'user', :spell => 'password')
      user.save
      get :index, :user => 'user', :password => 'password', :format => 'json'
      response.body.should have_json("/status[text() = 'ok']")
      session[:current_user_id].should_not be_nil
    end

    it "ユーザを取得できない場合は error を返す" do
      User.delete_all
      get :index, :user => 'user', :password => 'password', :format => 'json'
      response.body.should have_json("/status[text() = 'error']")
      session[:current_user_id].should be_nil
    end

    it "複数のユーザがいる場合でもちゃんと動作する" do
      alice = User.new(:screen_name => 'alice', :spell => 'password').tap{|x| x.save }
      bob = User.new(:screen_name => 'bob', :spell => 'password').tap{|x| x.save }

      get :index, :user => 'bob', :password => 'password', :format => 'json'
      response.body.should have_json("/status[text() = 'ok']")
      session[:current_user_id].should == bob.id
    end
  end
end
