# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../../../spec/spec_helper'

describe OmniAuth::Strategies::Local do
  before {
    @app = double
    allow(@app).to receive(:url_for) { '/localauth/login' }
    @strategy = OmniAuth::Strategies::Local.new({})
    allow(@strategy).to receive(:app) { @app }
    allow(@strategy).to receive(:script_name) { '/as' }
    allow(@strategy).to receive(:env) { {} }
    allow(@strategy).to receive(:call_app!)
    allow(LocalUser).to receive(:[]).with('testuser') { {'screen_name' => 'nickname'} }
  }

  context 'request phase' do
    before {
      _, _, @response = @strategy.request_phase
    }
    subject { @response }
    its(:status) { 302 }
    it { expect(subject.header['Location']).to eq '/as/localauth/login' }
  end

  context 'callback phase' do
    before {
      @request = {:username => 'testuser'}
      allow(@strategy).to receive(:request) { @request }
    }

    context 'valid user' do
      before {
        allow(@strategy).to receive(:valid_local_user?) { true }
        @strategy.callback_phase
      }
      subject { @strategy.info }
      its(['nickname']) { 'nickname' }
    end

    context 'invalid user' do
      before {
        allow(@strategy).to receive(:valid_local_user?) { false }
        _, _, @response =  @strategy.callback_phase
      }
      subject { @response }
      its(:status) { should == 302 }
      it { expect(subject.header['Location']).to match(/\/auth\/failure/) }
    end
  end
end
