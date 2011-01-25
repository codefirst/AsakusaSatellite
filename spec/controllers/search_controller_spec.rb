require 'spec_helper'

describe SearchController do

  describe "インデックス表示時には" do
    it "rooms に代入される" do
      get 'index'
      response.should be_success
      assigns[:rooms] != nil
    end
  end

  describe "検索時は" do
    it "ヒットするメッセージがあれば検索される" do
      Message.select.each { |r| r.delete }
      Room.select.each { |r| r.delete }
      room = Room.new
      room.save!
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      get :search, {:search => {:message => 'テスト'}}
      require 'pp'
      pp assigns[:results]
      assigns[:results].count.should == 1
      assigns[:results][0][:messages].count.should == 1
    end
    it "ヒットするメッセージがなければ検索されない" do
      Message.select.each { |r| r.delete }
      Room.select.each { |r| r.delete }
      room = Room.new
      room.save!
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      get :search, {:search => {:message => 'ポテト'}}
      assigns[:results].count.should == 1
      assigns[:results][0][:messages].count.should == 0
    end
  end

end
