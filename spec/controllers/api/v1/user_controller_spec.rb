# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::UserController do
  before do
    User.all.each{|u| u.delete }

    device = Device.new(:name => 'hogehoge_id',
      :device_name => 'hogehoge_phone',
      :device_type => 'iphone')
    devices = [device]

    @user = User.new(:name => 'name',
                     :screen_name => 'screen-name',
                     :profile_image_url => 'url',
                     :devices => devices,
                     :spell => 'spell')
    @user.save!
    User.new(:name => 'test',
             :screen_name => 'test-name',
             :profile_image_url => 'test-url',
             :spell => nil).save!
  end

  describe "show" do
    context "api_keyが一致" do
      before {
        get :show, :params => { :api_key => @user.spell, :format => 'json' }
      }
      subject { response.body }
      it { should have_json("/id[text() = '#{@user.id}']") }
      it { should have_json("/name[text() = 'name']") }
      it { should have_json("/screen_name[text() = 'screen-name']") }
      it { should have_json("/profile_image_url[text() = 'url']") }
    end

    context "api_keyが不一致" do
      before {
        get :show, :params => { :api_key => "peropero", :format => 'json' }
      }
      subject { response }
      its(:response_code) { should == 403 }
      its(:body) { should have_json("/status[text() = 'error']") }
      its(:body) { should have_json("/error[text() = 'user not found']") }
    end

    context "without api_key" do
      before {
        get :show, :params => { :api_key => nil, :format => 'json' }
      }
      subject { response }
      its(:response_code) { should == 403 }
      its(:body) { should have_json("/status[text() = 'error']") }
      its(:body) { should have_json("/error[text() = 'user not found']") }
    end
  end

  describe "update" do
    context "名前の変更" do
      before {
        post :update, :params => { :api_key => @user.spell, :format => 'json', :name => "modified name" }
      }
      subject { @user.reload.name }
      it { should == "modified name" }
    end

    context "アイコンの変更" do
      before {
        post :update, :params => { :api_key => @user.spell, :format => 'json', :profile_image_url => "http://example.com/somepic.jpg" }
      }
      subject { @user.reload.profile_image_url }
      it { should == "http://example.com/somepic.jpg" }
    end

    context "存在しないパラメータの変更" do
      before {
        post :update, :params => { :api_key => @user.spell, :format => 'json', :invalid_param => "evil value" }
      }
      subject { @user.reload }
      it { should_not respond_to :invalid_param }
    end
  end

  describe "add_device" do
    context "デバイスIDがない" do
      before {
        post :add_device, :params => { :api_key => @user.spell, :format => 'json', :name => 'device_name' }
        @user = @user.reload
      }
      subject { response }
      its(:response_code) { should == 500 }
      its(:body) { should have_json("/status[text() = 'error']") }
      its(:body) { should have_json("/error[text() = 'device id and name cannot be empty']") }
    end
    context "デバイス名がない" do
      before {
        post :add_device, :params => { :api_key => @user.spell, :format => 'json', :device => 'device_id' }
        @user = @user.reload
      }
      subject { response }
      its(:response_code) { should == 500 }
      its(:body) { should have_json("/status[text() = 'error']") }
      its(:body) { should have_json("/error[text() = 'device id and name cannot be empty']") }
    end
    context "api_keyが一致" do
      before {
        post :add_device, :params => { :api_key => @user.spell, :format => 'json', :device => 'device_id', :name => 'device_name' }
        @user = @user.reload
      }
      subject { @user.devices[1].name }
      it { should == 'device_id' }
    end
    context "api_keyが不一致" do
      before {
        post :add_device, :params => { :api_key => "peropero", :format => 'json', :device => 'device_id', :name => 'device_name' }
      }
      subject { response }
      its(:response_code) { should == 403 }
      its(:body) { should have_json("/status[text() = 'error']") }
      its(:body) { should have_json("/error[text() = 'user not found']") }
    end
    context "user.saveでエラー" do
      before {
        user = double 'user'
        devices = double 'devices'
        allow(devices).to receive_messages(:where => [double('device')])
        allow(user).to receive_messages(:save => false, :devices => devices, :to_json => '')
        allow(controller).to receive(:current_user).and_return(user)
        post :add_device, :params => { :api_key => @user.spell, :format => 'json', :device => 'device_id', :name => 'device_name' }
      }
      subject { response }
      its(:response_code) { should == 500 }
      its(:body) { should have_json("/status[text() = 'error']") }
      its(:body) { should have_json("/error[text() = 'cannot save device data']") }
    end
  end

  describe "delete_device" do
    context "デバイスIDがない" do
      before {
        post :delete_device, :params => { :api_key => @user.spell, :format => 'json' }
        @user = @user.reload
      }
      subject { response }
      its(:response_code) { should == 500 }
      its(:body) { should have_json("/status[text() = 'error']") }
      its(:body) { should have_json("/error[text() = 'device id cannot be empty']") }
    end
    context "api_keyが一致" do
      before {
        post :delete_device, :params => { :api_key => @user.spell, :format => 'json', :device => 'hogehoge_id' }
        @user = @user.reload
      }
      subject { @user.devices.where(:name => 'hogehoge_id').first }
      it { should be_nil }
    end
    context "api_keyが不一致" do
      before {
        post :delete_device, :params => { :api_key => "peropero", :format => 'json', :device => 'hogehoge_id' }
        @user = @user.reload
      }
      subject { @user.devices.where(:name => 'hogehoge_id').first }
      it { should_not be_nil }
    end
  end

end
