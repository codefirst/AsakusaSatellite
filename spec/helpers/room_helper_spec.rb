# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe RoomHelper do
  before {
    @room = double "room"
    allow(@room).to receive_messages(:deleted => false, :is_public => true, :accessible? => true, :nickname => 'nickname')
    @user = double 'user'
  }

  shared_examples_for 'room found' do
    before do
      @called = false
      allow(Room).to receive_messages(:any_of => [ @room ])

      expect(self).to receive(:current_user).and_return(@user)
      expect(self).not_to receive(:redirect_to)
    end

    describe "callbacked" do
      before { find_room(0){ @called = true } }
      subject { @called }
      it { should be_truthy }
    end
  end

  shared_examples_for 'room not found' do
    before do
      @called = false
      allow(Room).to receive_messages(:any_of => [])

      expect(self).to receive(:current_user).and_return(@user)
      expect(self).to receive(:redirect_to)
    end

    describe "callbacked" do
      before { find_room(0){ @called = true } }
      subject { @called }
      it { should be_falsey }
    end
  end

  describe "room not found" do
    before {
      allow(Room).to receive_messages(:any_of => [])
      expect(self).to receive(:current_user).and_return(@user)
      expect(self).to receive(:redirect_to)
    }
    it { find_room(0){} }
  end

  context "部屋がない" do
    before { allow(Room).to receive_messages(:any_of => []) }
    it_should_behave_like 'room not found'
  end

  context "部屋が削除されている" do
    before do
      allow(@room).to receive_messages(:deleted => true)
    end
    it_should_behave_like 'room not found'
  end

  context 'find by nickname' do
    before {
      expect(self).to receive(:current_user).and_return(@user)
      expect(self).not_to receive(:redirect_to)
      allow(Room).to receive_messages(:any_of => [ @room ])
    }
    subject { find_room('nickname'){ @room } }
    its(:nickname) { should == 'nickname' }
  end
end
