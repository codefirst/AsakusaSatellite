# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe ChatController do
  before do
    Room.delete_all
    @user = User.new(:profile_image_url => "http://example.com/profile.png").tap{|u| u.save! }
    @other = User.new.tap{|u| u.save! }
    @room = Room.new(:title => 'test').tap{|r| r.save! }
    @messages = (0..50).map do
      Message.new(:room => @room, :user => @user, :body => 'body').tap{|m| m.save! }
    end
    @message = @messages.first
    session[:current_user_id] = @user.id
  end

  describe "発言投稿" do
    describe "発言の更新" do
      it { expect {
          post :message, {:room_id => @room.id, :message => "メッセージ" }
        }.to change { Message.all.size }.by(1)
      }
    end

    describe "空メッセージは無視する" do
      it { expect {
          post :message, {:room_id => @room.id, :message => "" }
        }.to change { Message.all.size }.by(0)
      }
    end

    describe "添付つきメッセージの投稿" do
      before {
        @file = fixture_file_upload("#{Rails.root}/app/assets/images/logo.png")
      }

      describe "メッセージあり" do
        it { expect {
            post :message, {:room_id => @room.id, :message => "メッセージ", :file => @file }
          }.to change { Message.all.size }.by(1)
        }
      end

      describe "メッセージなし" do
        it { expect {
            post :message, {:room_id => @room.id, :message => "", :file => @file }
          }.to change { Message.all.size }.by(1)
        }
      end
    end

    describe "部屋の更新" do
      before {
        @now = Time.at(Time.now.to_i+100)
        Time.stub(:now) { @now.dup }
        post :message, {:room_id => @room.id, :message => "メッセージ" }
      }
      subject {
        Room.find @room.id
      }
      its(:updated_at) { should == @now  }
    end
  end

  describe "入室" do
    describe "ID を指定する" do
      before {
        session[:current_user_id] = nil
        get :room, {:id => @room.id }
      }
      subject {
        assigns[:messages].to_a
      }
      it { should have(20).records }
    end

    describe "ID を指定しない" do
      before { get :room }
      it { should redirect_to(:action => 'index') }
    end
  end

  describe "トップページ" do
    before do
      Room.all.each {|room| room.delete}
      Room.new(:title => 'test').save
      get :index
    end

    subject { assigns[:rooms] }
    it { should have(1).records }
    it { should be_all{|x| not x.deleted } }
  end

  describe "個別ページ" do
    context "prev and next" do
      before {
        get :show, :id => @messages[20].id, :c => 5
      }
      subject { assigns }
      its([:prev]) { should have(5).items }
      its([:next]) { should have(5).items }
    end
    context "not found" do
      it "send response with status code 302" do
        get :show, :id => "not_existing_id"
        response.response_code.should == 302
      end
    end
  end

  describe "next" do
    context "without offset" do
      before { get :next, :id => @messages[10].id }
      subject { assigns }
      its([:messages]) { should have(20).items }
    end
  end

  describe "prev" do
    context "without offset" do
      before { get :prev, :id => @messages[40].id }
      subject { assigns }
      its([:messages]) { should have(20).items }
    end

    context "with not exisiting message" do
      before { get :prev, :id => "undefined" }
      subject { assigns }
      its([:messages]) { should have(0).items }
    end
  end

  context "部屋が存在しない" do
    before {
      Room.delete_all
    }
    describe "発言投稿" do
      it { expect {
          post(:message, {:room_id => @room.id, :message => 'テストメッセージ'})
        }.to raise_error
      }
    end

    describe "入室" do
      before { get :room, {:id => @room.id } }
      subject { response }
      it { should redirect_to(:action => 'index') }
    end
  end

  context "ログインしていない" do
    before { session[:current_user_id] = nil }
    subject { post :message, {:room_id => @room.id, :message => "メッセージ" } }
    it { should redirect_to(:controller => 'chat') }
  end

  context "コントローラフック" do
    before {
      class DummyPluginListener < AsakusaSatellite::Hook::Listener
        def in_chatroom_controller(context)
          context[:controller].instance_eval do
            @added_in_hook = "test"
          end
        end
      end
    }
    describe "登録したフックが呼び出される" do
      before { get :room, {:id => @room.id } }
      subject { assigns }
      its([:added_in_hook]) { should == "test" }
    end
  end
end
