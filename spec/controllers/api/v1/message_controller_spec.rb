# -*- coding: utf-8-emacs -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::MessageController do
  before do
    User.all{|u| u.delete }
    session[:current_user_id] = nil

    @image_url = 'http://example.com/hoge.png'
    @user = User.new(:screen_name=>'user',
                     :name =>'name',
                     :spell => 'spell',
                     :profile_image_url => @image_url)
    @user.save!
    @other_user = User.new(:screen_name=>'user',
                           :name =>'name',
                           :spell => 'x-spell',
                           :profile_image_url => @image_url)
    @other_user.save!
    @message = Message.new(:body => 'hoge', :user => @user, :created_at => Time.now)
    @message.save!
    @room = Room.new(:title=>'hoge',:user=>@user)
    @room.save!
    Attachment.stub(:select){ nil }
  end

  describe "発言取得" do
    before {
      get :show, :id => @message.id, :format => 'json'
    }
    subject { response.body }
    it { should have_json("/screen_name[text() = 'user']") }
    it { should have_json("/body[text() = 'hoge']") }
    it { should have_json("/view") }
    it { should have_json("/profile_image_url[text() = '#{@image_url}']") }
    it {
      # permlinkがAPIのほうを差していない
      should have_json("/view[not(contains(text(), 'api'))]")
    }
  end

  share_examples_for '成功'  do
    subject { response.body }
    it { should have_json("/status[text() = 'ok']") }
  end

  share_examples_for '失敗'  do
    subject { response.body }
    it { should have_json("/status[text() = 'error']") }
  end

  describe "発言作成" do
    before {
      post :create, :room_id => @room.id, :message => 'message', :api_key => @user.spell
    }
    it_should_behave_like '成功'
    it { expect {
        post :create, :room_id => @room.id, :message => 'message', :api_key => @user.spell
      }.to change(Message.all.records, :size).by(1)
    }
  end

  describe "発言更新" do
    before {
      post :update, :id => @message.id, :message => 'modified', :api_key => @user.spell
    }
    it_should_behave_like '成功'
    subject { Message.find @message.id }
    its(:body) { should == 'modified' }
  end

  context "復活の呪文を間違えた" do
    describe "発言" do
      before {
        post :create, :room_id => @room.id, :message => 'message', :api_key => '(puke)'
      }
      it_should_behave_like '失敗'
    end
  end

=begin
  describe "メッセージ更新API" do
    it "ログインユーザは更新可能" do
      user = User.new
      user.save
      session[:current_user_id] = user.id
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :update, :id => message.id, :message => 'message'
      response.body.should have_json("/status[text() = 'ok']")
    end
    it "復活の呪文付きであれば該当ユーザで更新可能" do
      user = User.new(:name => 'user', :screen_name => 'user name', :spell => 'aaa')
      user.save
      session[:current_user_id] = nil
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :update, :id => message.id, :message => 'message', :api_key => user.spell
      response.body.should have_json("/status[text() = 'ok']")
    end
    it "他人が作成したメッセージ以外は更新できない" do
      user = User.new(:name => 'user', :screen_name => 'user name', :spell => 'aaa')
      user.save
      other_user = User.new
      other_user.save
      session[:current_user_id] = nil
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => other_user, :room => room)
      message.save
      post :update, :id => message.id, :message => 'message', :api_key => user.spell
      response.body.should have_json("/status[text() = 'error']")
    end
    it "非ログインユーザは更新できない" do
      user = User.new
      user.save
      session[:current_user_id] = nil
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :update, :id => message.id, :message => 'message'
      response.body.should have_json("/status[text() = 'error']")
    end
  end

  describe "メッセージ削除API" do
    it "ログインユーザは削除可能" do
      user = User.new
      user.save
      session[:current_user_id] = user.id
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :destroy, :id => message.id
      response.body.should have_json("/status[text() = 'ok']")
    end
    it "復活の呪文付きの場合は該当ユーザで削除可能" do
      user = User.new(:name => 'user', :screen_name => 'user name', :spell => 'aaa')
      user.save
      session[:current_user_id] = nil
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :destroy, :id => message.id, :api_key => user.spell
      response.body.should have_json("/status[text() = 'ok']")

    end
    it "他人が作成したメッセージ以外は削除できない" do
      user = User.new(:name => 'user', :screen_name => 'user name', :spell => 'aaa')
      user.save
      other_user = User.new
      other_user.save
      session[:current_user_id] = nil
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => other_user, :room => room)
      message.save
      post :destroy, :id => message.id, :api_key => user.spell
      response.body.should have_json("/status[text() = 'error']")
    end

    it "非ログインユーザは削除できない" do
      user = User.new
      user.save
      session[:current_user_id] = nil
      room = Room.new(:title => 'test')
      room.save
      message = Message.new(:user => user, :room => room)
      message.save
      post :destroy, :id => message.id
      response.body.should have_json("/status[text() = 'error']")
    end
  end

  describe "メッセージ取得API" do
    before do
      user = User.new(:name => 'test', :screen_name => 'test user', :profile_image_url => 'test')
      user.save!

      @room = Room.new(:title=>"test room", :user => user)
      @room.save!

      @m1 = Message.new(:body => 'm1', :user => user, :created_at => Time.now, :room => @room)
      @m2 = Message.new(:body => 'm2', :user => user, :created_at => Time.now, :room => @room)
      @m3 = Message.new(:body => 'm3', :user => user, :created_at => Time.now, :room => @room)

      @m1.save!
      @m2.save!
      @m3.save!
    end

    it "取得した発言には:viewが含まれる" do
      get :list, :room_id => @room.id, :format => 'json'
      response.body.should have_json("/view")
      assigns[:messages].size.should == 3
    end

    it "until_idをわたせば、それ以前のメッセージが取得できる" do
      get :list, :room_id => @room.id, :until_id => @m2.id , :format => 'json'
      assigns[:messages].size.should == 2
    end

    it "countをわたせば、件数が指定できる" do
      get :list, :room_id => @room.id, :until_id => @m2.id, :count => 1 , :format => 'json'
      assigns[:messages].size.should == 1
    end
  end
=end
end
