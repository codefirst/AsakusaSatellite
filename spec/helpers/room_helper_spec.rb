# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe RoomHelper do
  before {
    @room = mock "room"
    @room.stub(:deleted => false, :is_public => true, :accessible? => true, :nickname => 'nickname')
    @user = mock 'user'
  }

  share_examples_for 'room found' do
    before do
      @called = false
      Room.stub(:any_of => [ @room ])

      self.should_receive(:current_user).and_return(@user)
      self.should_not_receive(:redirect_to)
    end

    describe "callbacked" do
      before { find_room(0){ @called = true } }
      subject { @called }
      it { should be_true }
    end
  end

  share_examples_for 'room not found' do
    before do
      @called = false
      Room.stub(:any_of => [])

      self.should_receive(:current_user).and_return(@user)
      self.should_receive(:redirect_to)
    end

    describe "callbacked" do
      before { find_room(0){ @called = true } }
      subject { @called }
      it { should be_false }
    end
  end

  describe "room not found" do
    before {
      Room.stub(:any_of => [])
      self.should_receive(:current_user).and_return(@user)
      self.should_receive(:redirect_to)
    }
    it { find_room(0){} }
  end

  context "部屋がない" do
    before { Room.stub(:any_of => []) }
    it_should_behave_like 'room not found'
  end

  context "部屋が削除されている" do
    before do
      @room.stub(:deleted => true)
    end
    it_should_behave_like 'room not found'
  end

  context 'find by nickname' do
    before {
      self.should_receive(:current_user).and_return(@user)
      self.should_not_receive(:redirect_to)
      Room.stub(:any_of => [ @room ])
    }
    subject { find_room('nickname'){ @room } }
    its(:nickname) { should == 'nickname' }
  end
end
