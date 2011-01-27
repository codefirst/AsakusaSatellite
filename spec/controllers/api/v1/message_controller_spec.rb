require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::MessageController do
  describe "発言取得API" do
    it "1件取得すると :name, :body, :profile_image_url が取得できる" do
      image_url = 'http://example.com/hoge.png'
      user = mock_model(User)
      user.stub!(:name).and_return('user')
      user.stub!(:profile_image_url).and_return(image_url)
      message = Message.new(:body => 'hoge', :user => user)
      Message.stub!(:find).with(message.id).and_return(message)
      get :show, :id => message.id, :format => 'json'
      response.body.should have_json("/name[text() = 'user']")
      response.body.should have_json("/body[text() = 'hoge']")
      response.body.should have_json("/profile_image_url[text() = '#{image_url}']")
    end

    it "1件postする" do
      session[:current_user_id] = 1
      ChatHelper.stub!(:publish_message).and_return(true)
      pending('websocketにつなぎに行くのを切る方法が分からない')
      post :create, :room_id => 1, :message => 'message'
      response.body.should have_json("/profile_image_url[text() = '11']")
    end
  end
end
