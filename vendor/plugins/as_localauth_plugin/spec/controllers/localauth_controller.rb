require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'

describe LocalauthController do
  it "validなユーザはログインできる" do
    LocalUser.stub(:[]) do 
      {'password'=> 'test1'}
    end
    Digest::SHA1.stub(:hexdigest) { 'test1' }
    post :login, :login => {:username => 'testuser1', :password => 'test1'}
    session[:current_user_id].should_not be_nil
  end

  it "invalidなユーザはログインできない" do
    LocalUser.stub(:[]) do 
      {'password'=> 'test1'}
    end
    Digest::SHA1.stub(:hexdigest) { 'test2' }
    post :login, :login => {:username => 'testuser1', :password => 'test2'}
    session[:current_user_id].should be_nil
  end
  
end
