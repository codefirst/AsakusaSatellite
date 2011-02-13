require File.dirname(__FILE__) + '/../spec_helper'

describe Room do
  describe "all_live 実行時" do
    before(:each) do
      Room.select.each { |r| r.delete }
    end
    it "rooms が空なら長さ0の結果が返る" do
      rooms = Room.all_live
      rooms.count.should == 0
    end
    it "rooms が2個なら長さ2の結果が返る" do
      room = Room.new(:title => 'room1', :user => nil, :updated_at => Time.now)
      room.save
      room = Room.new(:title => 'room2', :user => nil, :updated_at => Time.now)
      room.save
      rooms = Room.all_live
      rooms.count.should == 2
    end
    it "rooms が2個でも1つ削除されているなら長さ1の結果が返る" do
      room = Room.new(:title => 'room1', :user => nil, :updated_at => Time.now)
      room.save
      room = Room.new(:title => 'room2', :user => nil, :updated_at => Time.now)
      room.deleted = true
      room.save
      rooms = Room.all_live
      rooms.count.should == 1
    end
  end

  describe "生成時" do
    it "タイトルが空の場合生成に失敗する" do
      Room.new(:title => '').save.should be_false
      Room.new(:title => nil).save.should be_false
      Room.new.save.should be_false
    end 
  end

end
