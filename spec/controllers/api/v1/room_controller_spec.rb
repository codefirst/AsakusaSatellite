# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::RoomController do
  describe "部屋取得API" do
    it "取得した発言には:viewが含まれる" do
      user = mock_model(User)
      user.stub!(:screen_name).and_return('user')
      user.stub!(:name).and_return('name')
      image_url = 'http://example.com/hoge.png'
      user.stub!(:profile_image_url).and_return(image_url)

      m1 = Message.new(:body => 'm1', :user => user, :created_at => Time.now)
      m2 = Message.new(:body => 'm2', :user => user, :created_at => Time.now)
      m3 = Message.new(:body => 'm3', :user => user, :created_at => Time.now)
      room = Room.new
      Message.stub!(:select).and_return([m1, m2, m3])
      Attachment.stub!(:select).and_return(nil)
      get :show, :id => room.id, :format => 'json'
      response.body.should have_json("/view")
    end
  end
end
