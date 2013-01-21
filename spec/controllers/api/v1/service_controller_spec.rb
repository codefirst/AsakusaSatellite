# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::ServiceController do
  context "without api key" do
    before {
      get :info, :format => 'json'
    }
    subject { response.body }
    it { should have_json("/status[text() = 'error']") }
  end

  context "with api key" do
    before {
      @user = User.new(:screen_name=>'user',
                       :name =>'name',
                       :spell => 'spell')
      @user.save!
      get :info, :format => 'json', :api_key => @user.spell
    }
    subject { response.body }
    it { should have_json("/message_pusher") }
    it { should have_json("/message_pusher/name") }
    it { should have_json("/message_pusher/param") }
  end
end
