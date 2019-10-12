# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController do
  context "ログイン時" do
    before do
      users = []
      @user = User.new
      allow(@user).to receive(:generate_spell){ "spell-1" }
      users << @user
      allow(User).to receive(:where){ users }

      session[:current_user_id] = @user.id
    end

    describe "index" do
      before  { get 'index' }
      subject { response }
      it { should be_ok }

      context "既に設定されている" do
        before  { @user.spell = 'spell-2'; get 'index' }
        subject { @user }
        its(:spell) { should == "spell-2" }
      end
    end
  end

  context "未ログイン時" do
    before { session[:current_user_id] = nil }
    describe "index" do
      before  { get 'index' }
      subject { response }
      it {
        should redirect_to(:controller => 'chat', :action => 'index')
      }
    end
  end
end
