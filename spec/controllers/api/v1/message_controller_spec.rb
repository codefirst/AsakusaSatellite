# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::MessageController do
  before do
    cleanup_db

    session[:current_user_id] = nil

    @image_url = 'http://example.com/hoge.png'
    @user = User.create!(:screen_name=>'user',
                     :name =>'name',
                     :spell => 'spell',
                     :profile_image_url => @image_url)

    @room = Room.create!(:title=>'hoge',:user=>@user, :nickname => 'nick')

    @messages = (0..50).map do
      Message.create!(:room => @room, :user => @user, :body => 'hoge')
    end
    @message = @messages.first

    @other_user = User.create!(:spell => 'other')
    @private_room = Room.new(:title => 'private', :is_public => false)
    @private_room.user = @other_user
    @private_room.save
    @secret_message = Message.create!(:room => @private_room, :user => @other_user, :body => 'secret message')

    allow(Attachment).to receive(:where){ nil }
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
    end

    describe "since_id と until_id を指定" do
      before {
        get :list, :room_id => @room.id, :since_id => @messages[24].id, :until_id => @messages[26].id , :count => 2, :format => 'json'
      }
      describe "response" do
        subject { response.body }
        it { should have_json("/id[text() = '#{@messages[24].id}']") }
        it { should have_json("/id[text() = '#{@messages[25].id}']") }
        it { should_not have_json("/id[text() = '#{@messages[26].id}']") }
      end
    end

    describe "newer_than と older_than を指定" do
      before {
        get :list, :room_id => @room.id, :newer_than => @messages[24].id, :older_than => @messages[27].id , :count => 4, :format => 'json'
      }
      describe "response" do
        subject { response.body }
        it { should_not have_json("/id[text() = '#{@messages[24].id}']") }
        it { should have_json("/id[text() = '#{@messages[25].id}']") }
        it { should have_json("/id[text() = '#{@messages[26].id}']") }
        it { should_not have_json("/id[text() = '#{@messages[27].id}']") }
      end
    end

    describe "until_idを指定" do
      before {
        get :list, :room_id => @room.id, :until_id => @messages[25].id , :format => 'json'
      }
      describe "response" do
        subject { response.body }
        it { should have_json("/id[text() = '#{@messages[24].id}']") }
        it { should have_json("/id[text() = '#{@messages[25].id}']") }
        it { should_not have_json("/id[text() = '#{@messages[26].id}']") }
      end
    end

    describe "older_than を指定" do
      before {
        get :list, :room_id => @room.id, :older_than => @messages[25].id , :format => 'json'
      }
      describe "response" do
        subject { response.body }
        it { should have_json("/id[text() = '#{@messages[23].id}']") }
        it { should have_json("/id[text() = '#{@messages[24].id}']") }
        it { should_not have_json("/id[text() = '#{@messages[25].id}']") }
      end
    end

    describe "since_idを指定" do
      before {
        get :list, :room_id => @room.id, :since_id => @messages[25].id , :format => 'json'
      }
      describe "response" do
        subject { response.body }
        it { should_not have_json("/id[text() = '#{@messages[24].id}']") }
        it { should have_json("/id[text() = '#{@messages[25].id}']") }
        it { should have_json("/id[text() = '#{@messages[26].id}']") }
      end
    end

    describe "newer_than を指定" do
      before {
        get :list, :room_id => @room.id, :newer_than => @messages[25].id , :format => 'json'
      }
      describe "response" do
        subject { response.body }
        it { should_not have_json("/id[text() = '#{@messages[25].id}']") }
        it { should have_json("/id[text() = '#{@messages[26].id}']") }
        it { should have_json("/id[text() = '#{@messages[27].id}']") }
      end
    end

    describe "パラメータ指定が無効" do
      describe "newer_than と since_id を指定" do
        before {
          get :list, :room_id => @room.id, :newer_than => @messages[25].id, :since_id => @messages[25].id, :format => 'json'
        }
        describe "response" do
          subject { response.body }
          it { should have_json("/status[text() = 'error']") }
        end
      end
      describe "older_than と until_id を指定" do
        before {
          get :list, :room_id => @room.id, :older_than => @messages[25].id, :until_id => @messages[25].id, :format => 'json'
        }
        describe "response" do
          subject { response.body }
          it { should have_json("/status[text() = 'error']") }
        end
      end
    end

    describe "order を指定" do
      describe "order に asc を指定" do
        before {
          get :list, :room_id => @room.id, :since_id => @messages[30].id, :count => 10, :order => 'asc', :format => 'json'
        }
        describe "response" do
          subject { response.body }
          it { should have_json("/id[text() = '#{@messages[30].id}']") }
          it { should_not have_json("/id[text() = '#{@messages[40].id}']") }
        end
        describe "response length" do
          subject { JSON.parse(response.body) }
          it { should have(10).items }
        end
      end
      describe "order に desc を指定" do
        before {
          get :list, :room_id => @room.id, :since_id => @messages[30].id, :count => 10, :order => 'desc', :format => 'json'
        }
        describe "response" do
          subject { response.body }
          it { should_not have_json("/id[text() = '#{@messages[30].id}']") }
          it { should have_json("/id[text() = '#{@messages[41].id}']") }
          it { should have_json("/id[text() = '#{@messages[50].id}']") }
        end
        describe "response length" do
          subject { JSON.parse(response.body) }
          it { should have(10).items }
        end
      end
    end


    describe "countを指定" do
      before {
        get :list, :room_id => @room.id, :count => 1 , :format => 'json'
      }
      describe "response" do
        subject { JSON.parse(response.body) }
        it { should have(1).items }
      end
    end

    describe "nickname" do
      before {
        get :list, :room_id => @room.nickname, :format => 'json'
      }
      describe "response" do
        subject { JSON.parse(response.body) }
        it { should have(20).items }
      end
    end
  end

  describe "プライベートルーム" do
    describe "一覧" do
      before {
        get :list, :room_id => @private_room.id, :format => 'json'
      }
      subject { response }
      its(:response_code) { should == 403 }
      its(:body) { should have_json("/status[text() = 'error']") }
    end

    describe "個別取得" do
      before {
        get :show, :id => @secret_message.id, :format => 'json'
      }
      subject { response }
      its(:response_code) { should == 403 }
      its(:body) { should have_json("/status[text() = 'error']") }
    end
   end

  shared_examples_for '成功'  do
    subject { response }
    its(:response_code) { should == 200 }
    its(:body) { should have_json("/status[text() = 'ok']") }
  end

  shared_examples_for '失敗'  do
    subject { response }
    its(:response_code) { should_not == 200 }
    its(:body) { should have_json("/status[text() = 'error']") }
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
      it { expect(response.body).to have_json("/message_id") }
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
      it { expect(response.body).to have_json("/message_id") }
    end

    describe "空メッセージは無視する" do
      before {
        post :create, :room_id => @room.id, :message => '', :api_key => @user.spell
      }
      it_should_behave_like '失敗'
      it { expect {
          post :create, :room_id => @room.id, :message => '', :api_key => @user.spell
        }.to change { Message.all.size }.by(0)
      }
    end

    describe "添付つきメッセージの投稿" do
      before {
        @file = fixture_file_upload("#{Rails.root}/app/assets/images/logo.png")
      }

      describe "メッセージあり" do
        before {
          post :create, :room_id => @room.id, :message => 'message', :api_key => @user.spell, :files => {"logo.png" => @file}
        }
        it_should_behave_like '成功'
        it { expect {
            post :create, :room_id => @room.id, :message => 'message', :api_key => @user.spell, :files => {"logo.png" => @file}
          }.to change { Message.all.size }.by(1)
        }
      end

      describe "メッセージなし" do
        before {
          post :create, :room_id => @room.id, :message => '', :api_key => @user.spell, :files => {"logo.png" => @file}
        }
        it_should_behave_like '成功'
        it { expect {
            post :create, :room_id => @room.id, :message => '', :api_key => @user.spell, :files => {"logo.png" => @file}
          }.to change { Message.all.size }.by(1)
        }
      end
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
      subject { response }
      its(:response_code) { should == 403 }
    end

    describe "発言更新" do
      before {
        post :update, :id => @message.id, :message => 'modified', :api_key => '(puke)'
      }
      it_should_behave_like '失敗'
      subject { response }
      its(:response_code) { should == 403 }
    end

    describe "発言更新" do
      before {
        post :destroy, :id => @message.id, :api_key => '(puke)'
      }
      it_should_behave_like '失敗'
      subject { response }
      its(:response_code) { should == 403 }
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
        subject { response }
        its(:response_code) { should == 403 }
      end
    end
    context "on the spot での更新" do
      describe "発言更新" do
        before {
          put :update, :id => @message.id, :message => 'modified', :api_key => @other_user.spell
        }
        it_should_behave_like '失敗'
        subject { response }
        its(:response_code) { should == 403 }
      end
    end


    describe "発言削除" do
      before {
        post :destroy, :id => @message.id, :api_key => @other_user.spell
      }
      it_should_behave_like '失敗'
      subject { response }
      its(:response_code) { should == 403 }
    end
  end

  describe "search" do
    context 'normal' do
      before {
        get :search, :room_id => @room.id, :query => 'hoge', :format => 'json'
      }
      subject { response.body }
      it { should have_json("//body[text() = 'hoge']") }
    end
    context 'empty query' do
      before {
        get :search, :room_id => @room.id, :format => 'json'
      }
      subject { response }
      its(:response_code) { should == 200 }
    end
    context 'private room' do
      before {
        get :search, :room_id => @private_room.id, :query => 'hoge', :format => 'json'
      }
      subject { response.body }
      it { should have_json("/status[text() = 'error']") }
    end
  end
end
