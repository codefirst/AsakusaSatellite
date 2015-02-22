# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper
describe RoomController do
  before do
    @user = User.create!
    @room = Room.create!(:title => 'title', :user => @user)
  end

  shared_examples_for '部屋を消せる'  do
    before { post :delete, :id => @room.id }
    describe "room" do
      subject { Room.where(:_id => @room.id).first }
      its(:deleted) { should be_truthy }
    end

    describe "response" do
      subject { response }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end
  end

  context "ログイン時" do
    before do
      user = User.create!
      session[:current_user_id] = user.id
    end
    it_should_behave_like '部屋を消せる'

    describe "存在しない部屋を消そうとする" do
      before { post :delete, :id => 0 }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end

    describe "部屋の保存に失敗する" do
      before {
        room = double "room"
        expect(room).to receive(:update_attributes).and_return(false)
        expect(Room).to receive(:with_room).and_yield(room)
      }

      describe "更新" do
        before { post :configure, :room => {
            :name => "title", :nickname => "nickname", :members => []
          } }
        it { should redirect_to(:controller => 'room', :action => 'configure') }
      end

      describe "削除" do
        before { post :delete, :id => @room.id }
        it { should redirect_to(:controller => 'chat', :action => 'index') }
      end
    end

    describe "部屋作成" do
      it { expect {
          post :create, {:room => {:title => 'foo' }}
        }.to change { Room.all.size }.by(1)
      }
    end

    describe "部屋作成失敗" do
      before do
        allow(Room).to receive(:new) { mock_model(Room, :update_attributes => false) }
        post :create, {:room => {:title => 'foo' }}
      end
      subject { response }
      it { should redirect_to(:controller => 'room', :action => 'create') }
    end

    describe "privateな部屋作成" do
      before {
          post :create, {:room => {:title => 'foo private', :is_public => false }}
      }
      subject { Room.last }
      its(:is_public) { should be_falsey }
    end

    describe "publicな部屋作成" do
      before {
          post :create, {:room => {:title => 'foo', :is_public => true }}
      }
      subject { Room.last }
      its(:is_public) { should be_truthy }
    end

    describe "/deleteにGET" do
      before { get :delete, :id => @room.id }
      subject { response }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end

    describe "/configure" do
      before do
        new_username = Time.now.to_s
        post :configure, :id => @room.id,
             :room => { :title => 'new title', :members => {1 => @user.name, 2 => new_username} }
        @room = Room.find(@room.id)
      end
      subject { @room }
      its(:title) { should == 'new title'}
      it { should redirect_to(:controller => 'room', :action => 'configure') }
    end

    describe "メンバーが部屋の設定画面を GET" do
      before { get :configure, :id => @room.id }
      it { expect(response).to render_template("room/configure") }
    end

    describe "メンバーが部屋の設定画面をニックネームで GET" do
      before {
        @room.update_attributes(:nickname => 'nickname2get')
        get :configure, :id => @room.nickname
      }
      it { expect(response).to render_template("room/configure") }
    end

    describe "存在しない部屋の設定を変更" do
      before { post :configure, :id => 0, :room => {:members => []} }
      it { should redirect_to :action => 'configure' }
    end
  end

  context "owner以外でログイン時" do
    before do
      session[:current_user_id] = @user.id
    end
    it_should_behave_like '部屋を消せる'
  end

  context "未ログイン時" do
    before { session[:current_user_id] = nil }

    describe "部屋作成" do
      before  { get :create }
      subject { response }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end

    describe "/configure" do
      before { post :configure, :id => @room.id }
      subject { response }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end

    describe "/deleteにPOST後" do
      before { post :delete, :id => @room.id }

      describe "room" do
        subject { Room.find @room.id }
        its(:deleted) { should be_falsey }
      end

      describe "response" do
        subject { response }
        it { should redirect_to(:controller => 'chat', :action => 'index') }
      end
    end

    describe "存在しない部屋を消そうとする" do
      before { post :delete, :id => @room.id }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end
  end
end
