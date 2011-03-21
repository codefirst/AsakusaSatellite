# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  describe "current_user" do
    context "ログイン時" do
      before do
        @user = User.new
        @user.save
        set_current_user @user
      end
      subject { helper }
      it { should be_logged }
      its(:current_user){ should == @user }
    end

    context "ログアウト時" do
      before { session[:current_user_id] = nil }
      subject { helper }
      it { should_not be_logged }
    end
  end

  describe "mine_type" do
    subject { helper }
    it { should be_image_mimetype('image/png') }
    it { should_not be_image_mimetype('text/plain') }
  end

#    helper.image_mimetype?('image/png').should be_true
#    helper.image_mimetype?('text/plain').should be_false
#  end
end
