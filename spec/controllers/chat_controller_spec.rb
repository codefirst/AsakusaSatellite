# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe ChatController do
  before do
    @user = User.new.tap{|u| u.save! }
    @other = User.new.tap{|u| u.save! }
    @room = Room.new(:title => 'test').tap{|r| r.save! }
    @messages = (0..50).map do
      Message.new(:room => @room, :user => @user, :body => 'body').tap{|m| m.save! }
    end
    @message = @messages.first
    session[:current_user_id] = @user.id
  end

  describe "発言投稿" do
    it { expect {
        post :message, {:room_id => @room.id, :message => "メッセージ" }
      }.to change(Message.all.records, :size).by(1)
    }

    describe "部屋" do
      before {
        @now = Time.now
        Time.stub(:now) { @now }
        post :message, {:room_id => @room.id, :message => "メッセージ" }
      }
      subject { Room.find @room.id }
      its(:updated_at) { should == @now }
    end
  end

  describe "入室" do
    before {
      session[:current_user_id] = nil
      get :room, {:id => @room.id}
    }
    subject { assigns }
    its([:messages]) { should have(20).records }
  end

  describe "発言更新" do
    context "発言者" do
      subject { Message.find(@message.id) }
      before {
        post :update_message_on_the_spot, {:id => @message.id, :value => 'modified'}
      }
      its(:body) { should == 'modified' }
    end

    context "非発言者" do
      before do
        session[:current_user_id] = @other.id
        post :update_message_on_the_spot, {:id => @message.id, :value => 'modified'}
      end
      subject { Message.find(@message.id) }
      its(:body) { should == @message.body }
    end
  end

  describe "部屋作成" do
    it { expect {
        post :room, {:room => {:title => 'foo' }}
      }.to change(Room.all.records, :size).by(1)
    }
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
    before {
      get :show, :id => @messages[20], :c => 5
    }
    subject { assigns }
    its([:prev]) { should have(5).items }
    its([:next]) { should have(5).items }
  end

  context "非ログイン時" do
    before { session[:current_user_id] = nil }

    it { expect {
        post :room, {:room => {:title => 'test'}}
      }.to change(Room.all.records, :size).by(0) }

    describe "部屋作成" do
      before  { post :room, {:room => {:title => 'test'} } }
      subject { response }
      it {
        should redirect_to(:controller => 'chat', :action => 'index')
      }
    end

    describe "部屋作成ページ" do
      before  { get :create }
      subject { response }
      it {
        should redirect_to(:controller => 'chat', :action => 'index')
      }
    end
  end

  context "部屋が存在しない" do
    before { @room.delete }
    describe "発言投稿" do
      it { expect {
          post(:message, {:room_id => room.id, :message => 'テストメッセージ'})
        }.to raise_error
      }
    end

    describe "入室" do
      before { get :room, {:id => @room.id } }
      subject { response }
      it { should redirect_to(:action => 'index') }
    end
  end
end
