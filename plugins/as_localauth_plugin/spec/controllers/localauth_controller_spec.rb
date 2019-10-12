# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'

describe LocalauthController do
  describe "/index redirect to /login" do
    before  { get :index }
    subject { response }
    it {
      should redirect_to(:controller => 'localauth', :action => 'login')
    }
  end

  describe "/login" do
    before  { get :login }
    subject { response }
    it { should be_ok }
  end
end
