require 'spec_helper'

describe AccountController do

  describe "GET 'index'" do
    it "should be successful" do
      user = mock_model(User)
      user.stub!(:spell).and_return('')
      user.stub!(:spell=)
      user.stub!(:save)
      User.stub!(:find).and_return(user)
      get 'index'
      response.should be_success
    end
  end

end
