require File.dirname(__FILE__) + '/../spec_helper'

describe Message do

  before do
    @body = 'これは本文です'
    @room_name = 'テストの部屋'
#    @room = mock_model(Room)
#    @room.stub!(:title).and_return(@room_name)
    @room = Room.new(:title => @room_name)
    @room.save!
    @message = Message.new(:body => @body)
    @message.save!
  end

  # ActiveGroonga の評価のため非常に基本的なspec
  it "本文を取得できる(trivial)" do
    @message.body.should == @body
  end

  it "部屋を外部参照する" do
    @message.room = @room
    @message.save!
    @message.room.title.should == @room_name
  end
end
