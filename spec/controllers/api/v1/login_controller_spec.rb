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
      User.select.each {|r| r.delete}
      get :index, :user => 'user', :password => 'password', :format => 'json'
      response.body.should have_json("/status[text() = 'error']")
      session[:current_user_id].should be_nil
    end

  end
end
