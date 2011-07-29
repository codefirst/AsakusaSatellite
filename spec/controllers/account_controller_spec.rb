# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController do
  context "ログイン時" do
    before do
      @user = mock_model(User)
      @user.stub(:id){ '42' }
      @user.stub(:spell){ @spell }
      @user.stub(:spell=){|s| @spell = s }
      @user.stub(:save)
      User.stub(:find){ @user.id }

      session[:current_user_id] = @user.id

      i = 0
      controller.stub(:generate_spell) {
        i += 1
        "spell-#{i}"
      }
    end

    describe "index" do
      before  { get 'index' }
      subject { response }
      it { should be_success }

      context "複数回アクセス" do
        before  { get 'index'; get 'index' }
        subject { @user }
        its(:spell) { should == "spell-1" }
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
