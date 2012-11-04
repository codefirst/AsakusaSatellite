# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'

describe RedmineauthController do
  before { Setting.stub(:[]).and_return(true) }

  describe "index にアクセスすると login に redirect する" do
    before  { get :index }
    subject { response }
    it {
      should redirect_to(:controller => 'redmineauth', :action => 'login')
    }
  end

  describe "login にアクセスすると成功する" do
    before  { get :login }
    subject { response }
    it { should be_success }
  end
end
