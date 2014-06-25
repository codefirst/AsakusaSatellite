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
  end
end
