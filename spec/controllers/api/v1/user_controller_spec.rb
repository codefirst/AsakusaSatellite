# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::UserController do
  before do
    User.all.each{|u| u.delete }
    @user = User.new(:name => 'name',
                     :screen_name => 'screen-name',
                     :profile_image_url => 'url',
                     :spell => 'spell')
    @user.save!
  end

  describe "show" do
    context "api_keyが一致" do
      before {
        get :show, :api_key => @user.spell, :format => 'json'
      }
      subject { response.body }
      it { should have_json("/id[text() = '#{@user.id}']") }
      it { should have_json("/name[text() = 'name']") }
      it { should have_json("/screen_name[text() = 'screen-name']") }
      it { should have_json("/profile_image_url[text() = 'url']") }
    end

    context "api_keyが不一致" do
      before {
        get :show, :api_key => "peropero", :format => 'json'
      }
      subject { response.body }
      it { should have_json("/status[text() = 'error']") }
      it { should have_json("/error[text() = 'user not found']") }
    end
  end

  describe "add_device" do
    context "api_keyが一致" do
      before {
        post :add_device, :api_key => @user.spell, :format => 'json', :device => 'device_id'
        @user = User.where(:_id => @user.id).first
      }
      subject { @user.devices[0].name }
      it { should == 'device_id' }
    end
    context "api_keyが不一致" do
      before {
        post :add_device, :api_key => "peropero", :format => 'json', :device => 'device_id'
      }
      subject { response }
      its(:response_code) { should == 403 }
      its(:body) { should have_json("/status[text() = 'error']") }
      its(:body) { should have_json("/error[text() = 'user not found']") }
    end
  end

end
