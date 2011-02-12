require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  it "ログインユーザをセットする" do
    user = User.new
    user.save
    helper.set_current_user(user)
    helper.current_user.id.should == user.id
  end

  it "画像の mimetypeを判別する" do
    helper.image_mimetype?('image/png').should be_true
    helper.image_mimetype?('text/plain').should be_false
  end
end
