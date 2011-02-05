require File.dirname(__FILE__) + '/../spec_helper'

describe Message do

  before do
    @body = 'これは本文です'
    @room_name = 'テストの部屋'
    @room = Room.new(:title => @room_name)
    @room.save!
    @user = User.new(:name => 'test user', :screen_name => 'test')
    @user.save!
    @message = Message.new(:body => @body, :user => @user)
    @message.save!
  end

  it "本文を取得できる" do
    @message.body.should == @body
  end

  it "部屋を外部参照する" do
    @message.room = @room
    @message.save!
    @message.room.title.should == @room_name
  end

  it "Hashに変換できる" do
    @message.to_hash.should == {
        "name" => @message.user.name,
        "created_at" => I18n.l(@message.created_at),
        "profile_image_url" => @message.user.profile_image_url,
        "html_body" => @message.body,
        "body" => @message.body,
        "attachment" => nil,
        "id" => @message.id,
        "screen_name" => @message.user.screen_name
    }
  end
  
end
