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
        Room.stub(:all_live){ [] }
        @find_by_text = Message.should_receive(:find_by_text).with(:text => 'foo', :rooms=>[]){ [] }
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
        @room.stub(:deleted => false,
                   :title   => "foo",
                   :id => 42,
                   :accessible? => true)

        Room.stub(:all_live => [ @room ])

        @find_room    = Room.should_receive(:where).with(:_id => '1'){ [ @room ] }
        @find_by_text = Message.
          should_receive(:find_by_text).
          with(:text => 'foo', :rooms => [ @room ], :limit => 20){ [] }
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
end
