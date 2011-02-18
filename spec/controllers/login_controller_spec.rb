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

    before(:type => :controller) do
      request.env["HTTP_REFERER"] = "/"
    end

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
      OAuth::RequestToken.stub!(:new).and_return(request_token)
      session[:request_token] = {:token => 'ccc', :secret => 'ddd'}
      env.merge :HTTP_REFERER => '/'
      post :oauth_callback, {:denied => nil}
    end
  end

end
