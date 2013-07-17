# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::MessageController do
  before do
    cleanup_db

    session[:current_user_id] = nil

    @image_url = 'http://example.com/hoge.png'
    @user = User.new(:screen_name=>'user',
                     :name =>'name',
                     :spell => 'spell',
                     :profile_image_url => @image_url)
    @user.save!

    @room = Room.new(:title=>'hoge',:user=>@user, :nickname => 'nick')
    @room.save!

    @messages = (0..50).map do
      Message.new(:room => @room, :user => @user, :body => 'hoge').tap{|m| m.save! }
    end
    @message = @messages.first

    @other_user = User.new(:spell => 'other')
    @other_user.save
    @private_room = Room.new(:title => 'private', :is_public => false)
    @private_room.user = @other_user
    @private_room.save
    @secret_message = Message.new(:room => @private_room, :user => @other_user, :body => 'secret message').tap{|m| m.save! }

    Attachment.stub(:where){ nil }
  end

  describe "特定の発言取得" do
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

  describe "秘密の部屋の特定の発言取得" do
    context "API key を指定しない" do
      before {
        get :show, :id => @secret_message.id, :format => 'json'
      }
      subject { response.body }
      it { should have_json("/status[text() = 'error']") }
    end

    context "API key を指定する" do
      before {
        get :show, :id => @secret_message.id, :format => 'json', :api_key => @other_user.spell
      }
      subject { response.body }
      it { should have_json("/body") }
    end
  end

  describe "発言一覧取得" do
    describe"オプションなし" do
      before {
        get :list, :room_id => @room.id, :format => 'json'
      }
      describe "response" do
        subject { response.body }
        it { should have_json('/view') }
        it { should have_json("/id[text() = '#{@messages[-1].id}']") }
        it { should have_json("/id[text() = '#{@messages[-20].id}']") }
        it { should_not have_json("/id[text() = '#{@messages[-21].id}']") }
      end
      describe "messages" do
        subject { assigns[:messages] }
        it { should have(20).items }
      end
    end

    describe "since_id と until_id を指定" do
      before {
        get :list, :room_id => @room.id, :since_id => @messages[24].id, :until_id => @messages[26].id , :count => 2, :format => 'json'
      }

      subject { assigns[:messages] }
      it { should be_include(@messages[24]) }
      it { should be_include(@messages[25]) }
      it { should_not be_include(@messages[26]) }
    end

    describe "until_idを指定" do
      before {
        get :list, :room_id => @room.id, :until_id => @messages[25].id , :format => 'json'
      }

      subject { assigns[:messages] }
      it { should be_include(@messages[24]) }
      it { should be_include(@messages[25]) }
      it { should_not be_include(@messages[26]) }
    end

    describe "since_idを指定" do
      before {
        get :list, :room_id => @room.id, :since_id => @messages[25].id , :format => 'json'
      }

      subject { assigns[:messages] }
      it { should_not be_include(@messages[24]) }
      it { should be_include(@messages[25]) }
      it { should be_include(@messages[26]) }
    end

    describe "order を指定" do
      before {
        get :list, :room_id => @room.id, :since_id => @messages[30].id, :count => 10, :order => 'desc', :format => 'json'
      }

      subject { assigns[:messages] }
      it { should have(10).items }
      it { should_not be_include(@messages[30]) }
      it { should be_include(@messages[41]) }
      it { should be_include(@messages[50]) }
    end


    describe "countを指定" do
      before {
        get :list, :room_id => @room.id, :count => 1 , :format => 'json'
      }
      subject { assigns[:messages] }
      it { should have(1).items }
    end

    describe "nickname" do
      before {
        get :list, :room_id => @room.nickname, :format => 'json'
      }
      subject { assigns[:messages] }
      it { should have(20).items }
    end
  end

  describe "プライベートルーム" do
    describe "一覧" do
      before {
        get :list, :room_id => @private_room.id, :format => 'json'
      }
      subject { response.body }
      it { should have_json("/status[text() = 'error']") }
    end

    describe "個別取得" do
      before {
        get :show, :id => @secret_message.id, :format => 'json'
      }
      subject { response.body }
      it { should have_json("/status[text() = 'error']") }
    end
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
    context "API 指定" do
      before {
        post :create, :room_id => @room.id, :message => 'message', :api_key => @user.spell
      }
      it_should_behave_like '成功'
      it { expect {
          post :create, :room_id => @room.id, :message => 'message', :api_key => @user.spell
        }.to change { Message.all.size }.by(1)
      }
      it { response.body.should have_json("/message_id") }
    end
    context "API 指定しない" do
      before {
        post :create, :room_id => @room.id, :message => 'message'
      }
      subject { response.body }
      it { should have_json("/error") }
    end

    context "nickname" do
      before {
        post :create, :room_id => @room.nickname, :message => 'message', :api_key => @user.spell
      }
      it_should_behave_like '成功'
      it { expect {
          post :create, :room_id => @room.id, :message => 'message', :api_key => @user.spell
        }.to change { Message.all.size }.by(1)
      }
      it { response.body.should have_json("/message_id") }
    end
  end

  describe "発言更新" do
    context "通常の更新" do
      before {
        post :update, :id => @message.id, :message => 'modified', :api_key => @user.spell
      }
      it_should_behave_like '成功'
      subject { Message.where(:_id => @message.id).first }
      its(:body) { should == 'modified' }
    end
    context "on the spot での更新" do
      before {
        put :update, :id => @message.id, :message => 'modified_again', :api_key => @user.spell
      }
      it_should_behave_like '成功'
      subject { Message.where(:_id => @message.id).first }
      its(:body) { should == 'modified_again' }
    end
  end

  describe "発言削除" do
    before {
      post :destroy, :id => @message.id, :api_key => @user.spell
    }
    it_should_behave_like '成功'
    subject { Message.where(:_id => @message.id).first }
    it { should be_nil }
  end

  context "復活の呪文を間違えた" do
    describe "発言" do
      before {
        post :create, :room_id => @room.id, :message => 'message', :api_key => '(puke)'
      }
      it_should_behave_like '失敗'
    end

    describe "発言更新" do
      before {
        post :update, :id => @message.id, :message => 'modified', :api_key => '(puke)'
      }
      it_should_behave_like '失敗'
    end

    describe "発言更新" do
      before {
        post :destroy, :id => @message.id, :api_key => '(puke)'
      }
      it_should_behave_like '失敗'
    end
  end

  context "別のユーザ" do
    before do
      @other_user = User.new(:screen_name=>'other',
                             :name =>'name',
                             :spell => 'x-spell',
                             :profile_image_url => @image_url)
      @other_user.save!
    end

    context "通常の更新" do
      describe "発言更新" do
        before {
          post :update, :id => @message.id, :message => 'modified', :api_key => @other_user.spell
        }
        it_should_behave_like '失敗'
      end
    end
    context "on the spot での更新" do
      describe "発言更新" do
        before {
          put :update, :id => @message.id, :message => 'modified', :api_key => @other_user.spell
        }
        it_should_behave_like '失敗'
      end
    end


    describe "発言削除" do
      before {
        post :destroy, :id => @message.id, :api_key => @other_user.spell
      }
      it_should_behave_like '失敗'
    end
  end
end
