# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before  do
    @user = User.new(:name => 'test user',
                     :screen_name => 'test',
                     :email => 'user@example.com',
                     :profile_image_url => 'http://example.com/profile.png',
                     :spell => 'spell')
  end

  subject { @user }

  it { should be_respond_to :name }
  it { should be_respond_to :screen_name }
  it { should be_respond_to :email }
  it { should be_respond_to :profile_image_url }
  it { should be_respond_to :spell }
  it { should be_respond_to :devices }
  describe "to_json" do
    subject { @user.to_json }
    its([:name]) { should == "test user" }
    its([:screen_name]) { should == "test" }
    its([:profile_image_url]) { should == "http://example.com/profile.png" }
    it { should_not have_key(:spell) }
    it { should_not have_key(:email) }
  end
end
