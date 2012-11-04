# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../../../spec/spec_helper'

describe OmniAuth::Strategies::Redmine do
  before {
    @app = mock
    @app.stub(:url_for) { '/redmineauth/login' }
    @strategy = OmniAuth::Strategies::Redmine.new({})
    @strategy.stub(:app) { @app }
    @strategy.stub(:script_name) { '/as' }
    @strategy.stub(:env) { {} }
    @strategy.stub(:call_app!)
  }

  context 'request phase' do
    before {
      _, _, @response = @strategy.request_phase
    }
    subject { @response }
    its(:status) { 302 }
    it { subject.header['Location'].should == '/as/redmineauth/login' }
  end

  context 'callback phase' do
    before {
      @strategy.stub(:request) { {:login_key => 'dummy', :login_name => 'name', :image_url => 'http://example.com/test.png'} }
    }

    context "validなユーザはログインできる" do
      VALID_API_RESPONSE = """<user>
<id>3</id>
<firstname>Firstname</firstname>
<lastname>LastName</lastname>
<mail>loginname@example.com</mail>
<created_on>2011-07-03T20:37:23+09:00</created_on>
<last_login_on>2011-07-03T21:33:31+09:00</last_login_on>
</user>"""
      before {
        RestClient.stub(:get).and_return(VALID_API_RESPONSE)
        @strategy.callback_phase
      }
      subject { @strategy.info }
      its([:name]) { should == 'Firstname LastName' }
      its([:nickname]) { should == 'name' }
      its([:image]) { should == 'http://example.com/test.png' }
    end

    it "invalidなユーザはログインできない" do
      RestClient.stub(:get).and_raise(RestClient::Exception)
      @strategy.callback_phase
      _, _, @response =  @strategy.callback_phase
      @response.header['Location'].should match(/\/auth\/failure/)
    end
  end
end
