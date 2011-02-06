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

  end

end
