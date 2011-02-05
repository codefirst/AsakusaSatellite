require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  it "フィールドを持つ" do
    user = User.new
    user.respond_to?(:spell).should be_true
    user.respond_to?(:profile_image_url).should be_true
    user.respond_to?(:screen_name).should be_true
    user.respond_to?(:name).should be_true
    user.respond_to?(:email).should be_true
    user.respond_to?(:id).should be_true
  end
end
