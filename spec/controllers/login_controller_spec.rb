# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe LoginController do
  context "ログアウト後" do
    before do
      @user = User.new.tap{|user| user.save! }
      session[:current_user_id] = @user.id
      post :logout
    end
    subject { session }
    its([:current_user_id]) { should be_nil }
  end

  describe "OAuth" do
    before do
      access_token = mock
      access_token.stub(:token){ 'aaa' }
      access_token.stub(:secret){ 'bbb' }
      request_token = mock
      request_token.stub(:get_access_token){ access_token }
      consumer_response = mock
      consumer_response.stub(:body){ "body" }
      Net::HTTPSuccess.stub(:===){ true }
      consumer = mock
      consumer.stub(:get_request_token)do
        OpenStruct.new({
                         :token => 'token',
                         :secret => 'secret',
                         :authorize_url => 'http://example.com/auth'
                       })
      end
      consumer.stub(:request){ consumer_response }
      OAuth::RequestToken.stub(:new){ request_token }
      LoginController.stub(:consumer){ consumer }
    end

    describe "/oauthにアクセスしたとき" do
      before { post :oauth }
      subject { response }
      it { should be_redirect }
    end

    context "denied時" do
      before do
        session[:oauth] = 'some key'
        post :oauth_callback, {:denied => true}
      end
      subject{ session }
      its([:oauth]) { should be_nil }
    end

    context "allow時" do
      before  do
        session[:request_token] = {:token => 'ccc', :secret => 'ddd'}
        session[:oauth_referer] = 'http://...'
      end

      context "jsonパース成功時" do
        before do
          JSON.stub(:parse){ { 'screen_name' => 'user'} }
          post :oauth_callback, {:denied => nil}
        end

        subject { session }
        its([:current_user_id]){ should_not be_nil }
      end

      context "jsonパース失敗時" do
        before do
          JSON.stub(:parse){ { 'screen_name' => nil } }
          post :oauth_callback, {:denied => nil}
        end

        subject { session }
        its([:current_user_id]){ should be_nil }
      end

      context "200 OKが返ってこない" do
        before do
          Net::HTTPSuccess.stub!(:===).and_return(false)
          post :oauth_callback, {:denied => nil}
        end

        subject { session }
        its([:current_user_id]){ should be_nil }
      end
    end
  end
end
