# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::RoomController do
  before do
    cleanup_db
    @user = User.new(:spell => 'spell')
    @user.save
    @room = Room.new(:title => 'title', :nickname => "test_room")
    @room.user = @user
    @room.save

    @other_user = User.new(:spell => 'other')
    @other_user.save
    @private_room = Room.new(:title => 'private', :is_public => false)
    @private_room.user = @other_user
    @private_room.save
  end

  shared_examples_for '成功する'  do
    subject { response }
    its(:response_code) { should == 200 }
    its(:body) { should have_json("/status[text() = 'ok']") }
  end

  shared_examples_for '失敗する'  do
    subject { response }
    its(:response_code) { should_not == 200 }
    its(:body) { should have_json("/status[text() = 'error']") }
  end

  describe "部屋作成" do
    describe "response" do
      before {
        post :create, :name => 'room name', :api_key => @user.spell, :format => 'json'
      }
      subject { response.body }
      it_should_behave_like '成功する'
      it { should have_json("/room_id") }
    end

    describe "DB" do
      it { expect {
          post :create, :name => 'room name', :api_key => @user.spell, :format => 'json'
        }.to change { Room.all.size }.by(1)
      }
    end
  end

  describe "部屋名の変更" do
    context 'id' do
      before {
        post :update, :id => @room.id, :name => 'new_name', :api_key => @user.spell, :format => 'json'
      }
      it_should_behave_like '成功する'
      subject { Room.find @room.id }
      its(:title) { should == 'new_name' }
    end

    context 'nickname' do
      before {
        post :update, :id => @room.nickname, :name => 'new name', :api_key => @user.spell, :format => 'json'
      }
      it_should_behave_like '成功する'
      subject { Room.find @room.id }
      its(:title) { should == 'new name' }
    end
  end

  describe "部屋の削除" do
    context 'id' do
      before {
        post :destroy, :id => @room.id, :api_key => @user.spell, :format => 'json'
      }
      it_should_behave_like '成功する'
      subject { Room.find @room.id }
      its(:deleted) { should be_truthy }
    end

    context 'nickname' do
      before {
        post :destroy, :id => @room.nickname, :api_key => @user.spell, :format => 'json'
      }
      it_should_behave_like '成功する'
      subject { Room.find @room.id }
      its(:deleted) { should be_truthy }
    end
  end

  describe "部屋の一覧" do
    context "パブリックな部屋" do
      before {
        post :list, :api_key => @user.spell, :format => 'json'
      }
      subject { response.body }

      it { should have_json("/id[text() = '#{@room._id}']") }
    end
    context "プライベートな部屋は見えない" do
      before {
        post :list, :api_key => @user.spell, :format => 'json'
      }
      subject { response.body }

      it { should have_json("/id[text() = '#{@room._id}']") }
      it { should_not have_json("/id[text() = '#{@private_room._id}']") }
    end
    context "作った人にはプライベートな部屋が見える" do
      before {
        post :list, :api_key => @other_user.spell, :format => 'json'
      }
      subject { response.body }

      it { should have_json("/id[text() = '#{@room._id}']") }
      it { should have_json("/id[text() = '#{@private_room._id}']") }
    end
    context "api_key 無しの場合は public な部屋のみ取得できる" do
      before {
        post :list, :format => 'json'
      }
      subject { response.body }

      it { should have_json("/id[text() = '#{@room._id}']") }
      it { should_not have_json("/id[text() = '#{@private_room._id}']") }
    end
  end

  describe "メンバの追加" do
    context 'id' do
      before {
        @another_user = User.new
        @another_user.save
        post :add_member, :id => @room.id, :user_id => @another_user.id, :api_key => @user.spell, :format => 'json'
        @room = Room.where(:_id =>@room.id).first
      }
      subject { @room.members[0] }
      its(:id) { should  == @another_user.id }
    end

    context 'nickname' do
      before {
        @another_user = User.new
        @another_user.save
        post :add_member, :id => @room.nickname, :user_id => @another_user.id, :api_key => @user.spell, :format => 'json'
        @room = Room.where(:_id =>@room.id).first
      }
      subject { @room.members[0] }
      its(:id) { should  == @another_user.id }
    end

    context 'duplicated member' do
      before {
        @another_user = User.new
        @another_user.save
        post :add_member, :id => @room.id, :user_id => @another_user.id, :api_key => @user.spell, :format => 'json'
        @size = Room.where(:_id =>@room.id).first.members.size
        post :add_member, :id => @room.id, :user_id => @another_user.id, :api_key => @user.spell, :format => 'json'
        @room = Room.where(:_id =>@room.id).first
      }
      describe "size not changed for duplicated" do
        subject { @room.members }
        its(:size) { should == @size }
      end
      describe "response is ok" do
        subject { response }
        its(:response_code) { should == 200 }
      end
    end
  end

  context "復活の呪文を間違えた" do
    describe "部屋の作成" do
      before {
        post :create, :name => 'room name', :api_key => '(puke)', :format => 'json'
      }
      it_should_behave_like '失敗する'
    end

    describe "部屋名の変更" do
      before {
        post :update, :id => @room.id, :name => 'new_name', :api_key => '(puke)', :format => 'json'
      }
      it_should_behave_like '失敗する'
      subject { Room.find @room.id }
      its(:title) { should == @room.title }
    end

    describe "部屋の削除" do
      before {
        post :destroy, :id => @room.id, :api_key => '(puke)', :format => 'json'
      }
      it_should_behave_like '失敗する'
      subject { Room.find @room.id }
      its(:deleted) { should be_falsey }
    end
  end

  context "非メンバによる操作" do
    before do
      @other_user = User.new(:spell => 'spell__')
      @other_user.save

      @room.is_public = false
      @room.save
    end

    after do
      @room.is_public = true
      @room.save
    end

    describe "メンバの追加" do
      before do
        @another_user = User.new
        @another_user.save
        post :add_member, :id => @room.id, :user_id => @another_user.id, :api_key => @other_user.spell, :format => 'json'
      end

      it_should_behave_like '失敗する'
      subject { response }
      its(:response_code) { should == 403 }
    end

    describe "部屋名の変更" do
      before {
        post :update, :id => @room.id, :name => 'new_name', :api_key => @other_user.spell, :format => 'json'
      }
      it_should_behave_like '失敗する'
      subject { Room.find @room.id }
      its(:title) { should == @room.title }
    end

    describe "部屋の削除" do
      before {
        post :destroy, :id => @room.id, :api_key => @other_user.spell, :format => 'json'
      }
      it_should_behave_like '失敗する'
      subject { Room.find @room.id }
      its(:deleted) { should be_falsey }
    end

    describe "部屋の一覧" do
      before {
        get :list, :api_key => @other_user.spell, :format => 'json'
      }
      subject { response.body }

      it { should_not have_json("/id[text() = '#{@room._id}']") }
    end
  end

  context "部屋の削除" do
    describe "未ログイン時" do
      before {
        post :destroy, :id => @room.id, :api_key => "", :format => 'json'
      }
      it_should_behave_like '失敗する'
    end

    describe "保存に失敗" do
      before {
        room = double "room"
        expect(room).to receive(:update_attributes).and_return(false)
        expect(Room).to receive(:with_room).and_yield(room)

        post :destroy, :id => @room.id, :api_key => @user.spell, :format => 'json'
      }
      it_should_behave_like '失敗する'
    end
  end
end
