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

    it "部屋がない場合はエラーメッセージとなる" do
      room = Room.new
      room.save
      room.delete
      lambda {
        post(:message, {:room_id => room.id, :message => 'テストメッセージ'})
      }.should raise_error
    end
  end

  describe "発言一覧時は" do
    it "デフォルトで該当する部屋のメッセージの20件を取得する" do
      room = Room.new
      room.save
      50.times do
        Message.new(:room => room).save
      end
      get :room, {:id => room.id}
      assigns[:messages].records.size.should == 20
    end
  end

  describe "発言更新時は" do
    it "該当メッセージの内容が更新される" do
      message = Message.new(:body => 'init')
      message.save
      get :update_message_on_the_spot, {:id => message.id, :value => 'modified'}
      Message.find(message.id).body.should == 'modified'
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
