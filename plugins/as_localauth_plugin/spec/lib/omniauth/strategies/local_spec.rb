# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../../../spec/spec_helper'

describe OmniAuth::Strategies::Local do
  before {
    @app = mock
    @app.stub(:url_for) { '/localauth/login' }
    @strategy = OmniAuth::Strategies::Local.new({})
    @strategy.stub(:app) { @app }
    @strategy.stub(:script_name) { '/as' }
    @strategy.stub(:env) { {} }
    @strategy.stub(:call_app!)
    LocalUser.stub(:[]).with('testuser') { {'screen_name' => 'nickname'} }
  }

  context 'request phase' do
    before {
      _, _, @response = @strategy.request_phase
    }
    subject { @response }
    its(:status) { 302 }
    it { subject.header['Location'].should == '/as/localauth/login' }
  end

  context 'callback phase' do
    before {
      @request = {:username => 'testuser'}
      @strategy.stub(:request) { @request }
    }

    context 'valid user' do
      before {
        @strategy.stub(:valid_local_user?) { true }
        @strategy.callback_phase
      }
      subject { @strategy.info }
      its(['nickname']) { 'nickname' }
    end

    context 'invalid user' do
      before {
        @strategy.stub(:valid_local_user?) { false }
        _, _, @response =  @strategy.callback_phase
      }
      subject { @response }
      its(:status) { should == 302 }
      it { subject.header['Location'].should match(/\/auth\/failure/) }
    end
  end
end
