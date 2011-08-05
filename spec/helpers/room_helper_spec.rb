# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe RoomHelper do
  share_examples_for 'found room' do
    before do
      @redirect = helper.should_not_receive(:redirect_to)
      helper.find_room(0, :not_auth => @not_auth){ @called = true }
    end

    describe "callbacked" do
      subject { @called }
      it { should be_true }
    end

    describe "redirect" do
      subject { @redirect }
      it { should be_expected_messages_received }
    end
  end
  share_examples_for 'not found room' do
    before do
      @redirect = helper.stub(:redirect_to)
      helper.find_room(0){ @called = true }
    end
    describe "callbacked" do
      subject { @called }
      it { should be_false }
    end

    describe "redirect" do
      subject { @redirect }
      it { should be_expected_messages_received }
    end
  end

  before do
    @room = mock "room"
    @room.stub(:deleted => false, :is_public=>true, :accessible? => true)

    @user = mock 'user'
    helper.stub(:current_user => @user)
    Room.stub(:where => [ @room ])
  end

  context "部屋がない" do
    before { Room.stub(:where => []) }
    it_should_behave_like 'not found room'
  end

  context "部屋が削除されている" do
    before do
      @room.stub(:deleted => true)
    end
    it_should_behave_like 'not found room'
  end

  context "ログインしていない" do
    before { helper.stub(:current_user => nil) }
    context "認証不要" do
      before { @not_auth = true }
      it_should_behave_like 'found room'
    end

    context "認証要" do
      it_should_behave_like 'not found room'
    end
  end

  context "ログインしている" do
    it_should_behave_like 'found room'
  end
end
