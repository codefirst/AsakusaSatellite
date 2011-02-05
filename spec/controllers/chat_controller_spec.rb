require File.dirname(__FILE__) + '/../spec_helper'

describe ChatController do
  describe "発言投稿時は" do
    before do
      user = User.new
      user.save
      session[:current_user_id] = user.id
    end

    it "一件messageが増える" do
      lambda {
        room = Room.new
        room.save!
        message = 'テストメッセージ'
        post :message, {:room_id => room.id, :message => message}
      }.should change(Message.all.records, :size).by(1)
    end
    it "部屋がない場合はエラーメッセージを表示する" do
      pending
      room = Room.new
      room.save
      room.delete if room
      post :message, {:room_id => room.id, :message => 'テストメッセージ'}
      #response.should.redirect_to :error
    end
  end

  describe "発言一覧時は" do
    it "デフォルトで該当する部屋のメッセージの1日分を取得する" do
      pending
      get :room, {:room_id => 1}
    end
  end

  describe "発言更新時は" do
    it "該当メッセージの更新日時が更新される" do
      pending
    end
  end

  describe "発言削除時は" do
    it "一件messageが減る" do
      pending
    end
    it "部屋がない場合はエラー" do
      room = Room.new
      room.save
      room.delete if room
      pending
      post :delete, {:room_id => 1, :message_id => 1}
      #response.should.redirect_to :error
    end
  end

  describe "部屋作成時は" do
    it "一件roomが増える" do
      title = 'テスト部屋'
      post :room, {:room => {:title => title}}
      assigns[:room].title.should == title
    end
  end
end
