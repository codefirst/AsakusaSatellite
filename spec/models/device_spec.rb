# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Device do
  before do
    @device = Device.new(:name => 'test-device-token-name',
                       :device_name => 'iphone10',
                       :device_type => 'android')
  end

  subject { @device }

  it { should be_respond_to :name }
  it { should be_respond_to :device_name }
  it { should be_respond_to :device_type }

  describe "to_json" do
    subject { @device.to_json }
    its([:name]) { should == "test-device-token-name" }
    its([:device_name]) { should == "iphone10" }
    its([:device_type]) { should == "android" }
  end

  context "Callbacks" do
    context "save" do
      before do
        user = User.create(:name => 'device_owner')
        device = Device.new(:name => 'test-device-token-name', :device_name => 'iphone10',
                            :device_type => 'android')
        user.devices = [device]
        @saved = nil
        Device.add_after_save { |device| @saved = device }
        device.save!
      end
      subject { @saved }
      it { should be }
    end

    context "destroy" do
      before do
        user = User.create(:name => 'device_owner')
        device = Device.new(:name => 'test-device-token-name', :device_name => 'iphone10',
                             :device_type => 'android')
        user.devices = [device]
        user.save!

        @destroyed = nil
        Device.add_after_destroy { |device| @destroyed = device }
        user.devices.destroy
      end
      subject { @destroyed }
      it { should be }
    end

    context "ios?" do
      context 'nil' do
        subject { Device.new(:device_type => nil) }
        its(:ios?) { should be_truthy }
      end
      context 'iphone' do
        subject { Device.new(:device_type => 'iphone') }
        its(:ios?) { should be_truthy }
      end
      context 'android' do
        subject { Device.new(:device_type => 'indroid') }
        its(:ios?) { should be_falsey }
      end
    end

  end
end
