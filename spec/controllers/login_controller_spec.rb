require File.dirname(__FILE__) + '/../spec_helper'

describe LoginController do
  it "ログアウトするとsessionからIDが消える" do
    user = User.new
    user.save
    session[:current_user_id] = user.id
    session[:current_user_id].nil?.should be_false
    post :logout
    session[:current_user_id].nil?.should be_true
  end

  it "oauth にアクセスするとリダイレクトされる" do
    post :oauth
    response.should be_redirect
  end

  describe "OAuth の callback時" do

    it "deniedパラメータが存在する場合はセッションからoauthパラメータを削除する" do
      session[:oauth] = 'a'
      post :oauth_callback, {:denied => true}
      session[:oauth].nil?.should be_true
    end

    it "deniedパラメータがなければログインユーザを作成しセッションに格納する" do
      access_token = mock
      access_token.stub!(:token).and_return('aaa')
      access_token.stub!(:secret).and_return('bbb')
      request_token = mock
      request_token.stub!(:get_access_token).and_return(access_token)
      consumer_response = mock
      consumer_response.stub!(:body).and_return("body")
      Net::HTTPSuccess.stub!(:===).and_return(true)
      consumer = mock
      consumer.stub(:request).and_return(consumer_response)
      OAuth::RequestToken.stub!(:new).and_return(request_token)
      LoginController.stub!(:consumer).and_return(consumer)
      JSON.stub!(:parse).and_return('screen_name' => 'user')
      session[:request_token] = {:token => 'ccc', :secret => 'ddd'}
      session[:oauth_referer] = 'http://...'
      post :oauth_callback, {:denied => nil}
      session[:current_user_id].should_not be_nil
    end

    it "screen_nameパラメータが返って来ないときはログインに失敗する" do
      access_token = mock
      access_token.stub!(:token).and_return('aaa')
      access_token.stub!(:secret).and_return('bbb')
      request_token = mock
      request_token.stub!(:get_access_token).and_return(access_token)
      consumer_response = mock
      consumer_response.stub!(:body).and_return("body")
      Net::HTTPSuccess.stub!(:===).and_return(true)
      consumer = mock
      consumer.stub(:request).and_return(consumer_response)
      OAuth::RequestToken.stub!(:new).and_return(request_token)
      LoginController.stub!(:consumer).and_return(consumer)
      JSON.stub!(:parse).and_return('screen_name' => nil)
      session[:request_token] = {:token => 'ccc', :secret => 'ddd'}
      session[:oauth_referer] = 'http://...'
      post :oauth_callback, {:denied => nil}
      session[:current_user_id].should be_nil
    end

    it "Status OK が返って来ないときはログインに失敗する" do
      access_token = mock
      access_token.stub!(:token).and_return('aaa')
      access_token.stub!(:secret).and_return('bbb')
      request_token = mock
      request_token.stub!(:get_access_token).and_return(access_token)
      consumer_response = mock
      consumer_response.stub!(:body).and_return("body")
      Net::HTTPSuccess.stub!(:===).and_return(false)
      consumer = mock
      consumer.stub(:request).and_return(nil)
      OAuth::RequestToken.stub!(:new).and_return(request_token)
      LoginController.stub!(:consumer).and_return(consumer)
      JSON.stub!(:parse).and_return('screen_name' => nil)
      session[:request_token] = {:token => 'ccc', :secret => 'ddd'}
      session[:oauth_referer] = 'http://...'
      post :oauth_callback, {:denied => nil}
      session[:current_user_id].should be_nil
    end

  end

end
