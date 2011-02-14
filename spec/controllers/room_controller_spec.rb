require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper
describe RoomController do
  before do
    user = User.new
    user.save
    session[:current_user_id] = user.id
    @room = Room.new(:title => 'title', :user => user)
    @room.save
   end

  it "deleteにアクセスすると指定した部屋に削除フラグが付く" do
    post :delete, :id => @room.id
    @room = Room.find(@room.id)
    @room.deleted.should be_true
  end

  it "ログインしていないユーザは部屋を削除できない" do
    session[:current_user_id] = nil 
    post :delete, :id => @room.id
    Room.find(@room.id).deleted.should be_false
  end
end
