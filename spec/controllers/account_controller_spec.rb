require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController do

  describe "/index へアクセスする" do
    it "ログインしている場合は status success" do
      user = mock_model(User)
      user.stub!(:spell).and_return('')
      user.stub!(:spell=)
      user.stub!(:save)
      User.stub!(:find).and_return(user)
      get 'index'
      response.should be_success
    end

    it "ログインしていない場合はトップページへリダイレクトする" do
      session[:current_user_id] = nil
      get 'index'
      response.should redirect_to(:controller => 'chat', :action => 'index')
    end
  end

end
