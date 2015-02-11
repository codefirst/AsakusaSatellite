# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../../../spec/spec_helper'

describe OmniAuth::Strategies::Redmine do
  before {
    @app = double
    allow(@app).to receive(:url_for) { '/redmineauth/login' }
    @strategy = OmniAuth::Strategies::Redmine.new({})
    allow(@strategy).to receive(:app) { @app }
    allow(@strategy).to receive(:script_name) { '/as' }
    allow(@strategy).to receive(:env) { {} }
    allow(@strategy).to receive(:call_app!)
  }

  context 'request phase' do
    before {
      _, _, @response = @strategy.request_phase
    }
    subject { @response }
    its(:status) { 302 }
    it { expect(subject.header['Location']).to eq '/as/redmineauth/login' }
  end

  context 'callback phase' do
    before {
      allow(@strategy).to receive(:request) { {:login_key => 'dummy', :login_name => 'name', :image_url => 'http://example.com/test.png'} }
      allow(@strategy).to receive(:redmine_users_url) { '' }
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
        allow(RestClient).to receive(:get).and_return(VALID_API_RESPONSE)
        @strategy.callback_phase
      }
      subject { @strategy.info }
      its([:name]) { should == 'Firstname LastName' }
      its([:nickname]) { should == 'name' }
      its([:image]) { should == 'http://example.com/test.png' }
    end

    it "invalidなユーザはログインできない" do
      allow(RestClient).to receive(:get).and_raise(RestClient::Exception)
      @strategy.callback_phase
      _, _, @response =  @strategy.callback_phase
      expect(@response.header['Location']).to match(/\/auth\/failure/)
    end
  end
end
