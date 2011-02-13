require File.dirname(__FILE__) + '/../../spec_helper'

describe "chat/room.html.haml" do
  before do
    @owner = User.new
    @owner.save
    @room = Room.new(:title => 'title', :user => @owner)
    @room.save
    @messages = []
  end

  it "オーナーはタイトルを修正できる" do
    session[:current_user_id] = @owner.id 
    render 
    rendered.should =~ /on_the_spot_editing/
  end
  it "オーナーじゃないユーザはタイトルを修正できない" do
    user = User.new
    user.save
    session[:current_user_id] = user.id 
    render 
    rendered.should_not =~ /on_the_spot_editing/
  end
  it "ログインしていないユーザはタイトルを修正できない" do
    session[:current_user_id] = nil 
    render 
    rendered.should_not =~ /on_the_spot_editing/
  end
end

