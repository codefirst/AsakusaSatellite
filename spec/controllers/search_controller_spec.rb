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
      before { get :search, :params => { :search => {:message => ''} } }
      subject { response }
      it { should redirect_to(:controller => 'search', :action => 'index') }
    end

    context "部屋指定なし" do
      before do
        allow(Room).to receive(:all_live).and_return([])
        @find_by_text = expect(Message).to receive(:find_by_text).with(:text => 'foo', :rooms=>[], :limit => SearchController::INTERSECTION_SEARCH_LIMIT){ [] }
        get :search, :params => { :search => {:message => 'foo'} }
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
        @room = double
        allow(@room).to receive_messages(:deleted => false,
                   :title   => "foo",
                   :id => 42,
                   :accessible? => true)

        allow(Room).to receive_messages(:all_live => [ @room ])

        @find_room    = expect(Room).to receive(:any_of).
          with({:_id => '1'}, {:nickname => '1'}){ [ @room ] }
        @find_by_text = expect(Message).to receive(:find_by_text).
          with(:text => 'foo', :rooms => [ @room ], :limit => 20){ [] }
        get :search, :params => { :search => {:message => 'foo'}, :room => { :id => '1' } }
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

  describe "search_more" do
    context "search_message が空" do
      before { get :search_more, :params => { :room_id => 1 } }
      subject { assigns[:results] }
      it { should be_nil }
    end

    context "room_id が空" do
      before { get :search_more, :params => { :search_message => 'foo' } }
      subject { assigns[:results] }
      it { should be_nil }
    end

    context "存在しない部屋" do
      before { get :search_more, :params => { :search_message => 'foo', :room_id => 'not_exisiting_room_id'} }
      subject { response }
      it { should redirect_to(:controller => 'chat', :action => 'index') }
    end

    context "検索結果がある" do
      before do
        @room = double
        allow(@room).to receive_messages(:deleted => false,
                   :_id => 42,
                   :accessible? => true)
        allow(Room).to receive_messages(:all_live => [ @room ])
        allow(Room).to receive(:any_of).with({:_id => '1'}, {:nickname => '1'}){ [ @room ] }
        allow(Message).to receive(:find_by_text) { [{ :room => @room, :messages => [Message.new] }] }
        get :search_more, :params => { :id => 1, :search_message => 'foo', :room_id => 1 }
      end
      subject { assigns[:results] }
      its(:size) { should == 1 }
    end
  end
end
