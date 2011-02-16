require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do

  describe "インデックス表示時には" do
    it "rooms に代入される" do
      get 'index'
      response.should be_success
      assigns[:rooms] != nil
    end
  end

  describe "検索時は" do
    it "検索文字列が空なら検索ページにリダイレクト" do
      get :search, {:search => {:message => ''}}
      response.should redirect_to(:controller => 'search', :action => 'index')
    end
    it "ヒットするメッセージがあれば検索される" do
      Message.select.each { |r| r.delete }
      Room.select.each { |r| r.delete }
      room = Room.new(:title => 'test')
      room.save!
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      get :search, {:search => {:message => 'テスト'}}
      assigns[:results].count.should == 1
      assigns[:results][0][:messages].count.should == 1
    end
    it "ヒットするメッセージがなければ検索されない" do
      Message.select.each { |r| r.delete }
      Room.select.each { |r| r.delete }
      room = Room.new(:title => 'test')
      room.save!
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      get :search, {:search => {:message => 'ポテト'}}
      assigns[:results].count.should == 1
      assigns[:results][0][:messages].count.should == 0
    end
    it "部屋番号を指定すると一致する部屋だけ返す" do
      Message.select.each { |r| r.delete }
      Room.select.each { |r| r.delete }
      room = Room.new(:title => 'test')
      room.save!
      room_id = room.id
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      room = Room.new(:title => 'test')
      room.save!
      message = Message.new
      message.body = 'テストメッセージ'
      message.room = room
      message.save!
      get :search, {:search => {:message => 'テスト'}, :room => {:id => room_id}}
      assigns[:results].count.should == 1
      assigns[:results][0][:messages].count.should == 1
      assigns[:results][0][:room].id.should == room_id
     end
  end

end
