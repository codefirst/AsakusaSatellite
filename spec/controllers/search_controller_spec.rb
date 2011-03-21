# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'


describe SearchController do
  describe "index" do
    before { get 'index' }

    describe "response" do
      subject { response }
      it { should be_success }
    end

    describe "assigns" do
      subject { assigns[:rooms] }
      it { should_not be_nil }
    end
  end

  describe "search" do
    context "空文字列" do
      before { get :search, :search => {:message => ''} }
      subject { response }
      it { should redirect_to(:controller => 'search', :action => 'index') }
    end

    context "部屋指定なし" do
      before do
        @find_by_text = Message.should_receive(:find_by_text).with(:text => 'foo'){ [] }
        get :search, :search => {:message => 'foo'}
      end

      describe "Message.find_by_text" do
        subject { @find_by_text }
        it { should be_expected_messages_received }
      end

      describe "results" do
        subject { assigns[:results] }
        it { should_not be_nil }
      end
    end

    context "部屋指定あり" do
      before do
        @room = mock
        @room.stub(:deleted){ false }
        @find_room    = Room.should_receive(:find).with('1'){ @room }
        @find_by_text = Message.
          should_receive(:find_by_text).
          with(:text => 'foo',:rooms => [ @room ]){ [] }
        get :search, :search => {:message => 'foo'}, :room => { :id => '1' }
      end

      describe "Message.find_by_text" do
        subject { @find_by_text }
        it { should be_expected_messages_received }
      end

      describe "Room.find" do
        subject { @find_room }
        it { should be_expected_messages_received }
      end

      describe "results" do
        subject { assigns[:results] }
        it { should_not be_nil }
      end
    end
  end

=begin
  describe "インデックス表示時には" do
    it "rooms に代入される" do
      get 'index'
      response.should be_success
      assigns[:rooms] != nil
    end
  end

  describe "検索時は" do
    it "ヒットするメッセージがあれば検索される" do
      Message.select.each { |r| r.delete }
      Room.select.each { |r| r.delete }
      room = Room.new(:title => 'test')
      room.save!
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      get :search, {:search => {:message => 'テスト'}}
      assigns[:results].count.should == 1
      assigns[:results][0][:messages].count.should == 1
    end
    it "ヒットするメッセージがなければ検索されない" do
      Message.select.each { |r| r.delete }
      Room.select.each { |r| r.delete }
      room = Room.new(:title => 'test')
      room.save!
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      get :search, {:search => {:message => 'ポテト'}}
      assigns[:results].count.should == 1
      assigns[:results][0][:messages].count.should == 0
    end
    it "部屋番号を指定すると一致する部屋だけ返す" do
      Message.select.each { |r| r.delete }
      Room.select.each { |r| r.delete }
      room = Room.new(:title => 'test')
      room.save!
      room_id = room.id
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      room = Room.new(:title => 'test')
      room.save!
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      get :search, {:search => {:message => 'テスト'}, :room => {:id => room_id}}
      assigns[:results].count.should == 1
      assigns[:results][0][:messages].count.should == 1
      assigns[:results][0][:room].id.should == room_id
     end
  end
=end

end
