require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'

describe RedmineauthController do
  before { Setting.stub(:[]).and_return(true) }

  describe "index にアクセスすると login に redirect する" do
    before  { get :index }
    subject { response }
    it {
      should redirect_to(:controller => 'redmineauth', :action => 'login')
    }
  end

  it "validなユーザはログインできる" do
    response = """<user>
<id>3</id>
<login>loginname</login>
<firstname>Firstname</firstname>
<lastname>LastName</lastname>
<mail>loginname@example.com</mail>
<created_on>2011-07-03T20:37:23+09:00</created_on>
<last_login_on>2011-07-03T21:33:31+09:00</last_login_on>
</user>"""
    RestClient.stub(:get).and_return(response)
    post :login, :login => {:key => 'dummy'}
    session[:current_user_id].should_not be_nil
  end

  it "invalidなユーザはログインできない" do
    RestClient.stub(:get).and_raise(RestClient::Exception)
    post :login, :login => {:key => 'dummy'}
    session[:current_user_id].should be_nil
  end

end
