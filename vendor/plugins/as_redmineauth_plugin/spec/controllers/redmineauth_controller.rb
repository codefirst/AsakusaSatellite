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

  VALID_API_RESPONSE = """<user>
<id>3</id>
<login>loginname</login>
<firstname>Firstname</firstname>
<lastname>LastName</lastname>
<mail>loginname@example.com</mail>
<created_on>2011-07-03T20:37:23+09:00</created_on>
<last_login_on>2011-07-03T21:33:31+09:00</last_login_on>
</user>"""

  it "validなユーザはログインできる" do
    RestClient.stub(:get).and_return(VALID_API_RESPONSE)
    post :login, :login => {:key => 'dummy'}
    session[:current_user_id].should_not be_nil
  end

  it "invalidなユーザはログインできない" do
    RestClient.stub(:get).and_raise(RestClient::Exception)
    post :login, :login => {:key => 'dummy'}
    session[:current_user_id].should be_nil
  end

  it "一度ログインしたユーザは同じユーザで再度ログインできる" do
    RestClient.stub(:get).and_return(VALID_API_RESPONSE)
    post :login, :login => {:key => 'dummy'}
    uid = session[:current_user_id]

    post :login, :login => {:key => 'dummy'}
    session[:current_user_id].should == uid
  end

end
