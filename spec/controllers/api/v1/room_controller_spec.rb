# -*- coding: utf-8 -*-
# -*- codi6ng: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::RoomController do
  before do
    User.delete_all
    @user = User.new(:spell => 'spell')
    @user.save
    @room = Room.new(:title => 'title')
    @room.user = @user
    @room.save
  end

  share_examples_for '成功する'  do
    subject { response.body }
    it { should have_json("/status[text() = 'ok']") }
  end

  share_examples_for '失敗する'  do
    subject { response.body }
    it { should have_json("/status[text() = 'error']") }
  end

  describe "部屋作成" do
    describe "response" do
      before {
        post :create, :name => 'room name', :api_key => @user.spell, :format => 'json'
      }
      it_should_behave_like '成功する'
    end

    describe "DB" do
      it { expect {
          post :create, :name => 'room name', :api_key => @user.spell, :format => 'json'
        }.to change(Room.all, :size).by(1)
      }
    end
  end

  describe "部屋名の変更" do
    before {
      post :update, :id => @room.id, :name => 'new_name', :api_key => @user.spell, :format => 'json'
    }
    it_should_behave_like '成功する'
    subject { Room.find @room.id }
    its(:title) { should == 'new_name' }
  end

  describe "部屋の削除" do
    before {
      post :destroy, :id => @room.id, :api_key => @user.spell, :format => 'json'
    }
    it_should_behave_like '成功する'
    subject { Room.find @room.id }
    its(:deleted) { should be_true }
  end

  describe "部屋の一覧" do
    before {
      post :list, :format => 'json'
    }
    subject { response.body }

    it { should have_json("/name[text() = '#{@room.title}']") }
  end

  describe "メンバの追加" do
    before {
      @another_user = User.new
      @another_user.save
      post :add_member, :id => @room.id, :user_id => @another_user.id, :api_key => @user.spell, :format => 'json'
      @room = Room.where(:_id =>@room.id).first
    }
    subject { @room.members[0] }
    its(:id) { should  == @another_user.id }
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
      its(:deleted) { should be_false }
    end
  end
end
