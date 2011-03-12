require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::UserController do
  describe "ユーザ取得API" do
    it "復活の呪文をキーにしてユーザ情報を取得する" do
      user = User.new(:name => 'name',
                      :screen_name => 'screen_name',
                      :profile_image_url => 'url',
                      :spell => 'spell')
      user.save
      get :show, :api_key => user.spell, :format => 'json'
      response.body.should have_json("/id")
      response.body.should have_json("/name")
      response.body.should have_json("/screen_name")
      response.body.should have_json("/profile_image_url")
    end
    
  end
end
