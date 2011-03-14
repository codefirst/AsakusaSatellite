require File.dirname(__FILE__) + '/../../spec_helper'

describe "chat/room.html.haml" do
  before do
    @owner = User.new
    @owner.save
    @room = Room.new(:title => 'title', :user => @owner)
    @room.save
    @messages = []
  end

end

