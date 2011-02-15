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

    it "since_dateパラメータを渡すと指定日以降のメッセージを返す" do
      user = User.new(:name => 'test', :screen_name => 'test user', :profile_image_url => 'test')
      user.save
      room = Room.new(:title => 'title', :user => user)
      room.save
      message1 = Message.new(:user => user, :room => room,
        :body => 'message1', :created_at => Date.new(2011, 1, 1).beginning_of_day.to_i)
      message1.save
      message2 = Message.new(:user => user, :room => room,
        :body => 'message2', :created_at => Date.new(2011, 1, 2).beginning_of_day.to_i)
      message2.save
      get :show, :id => room.id, :since_date => Date.new(2011, 1, 2).strftime("%Y-%m-%d"), :format => 'json'
      assigns[:messages].records.size.should == 2
      response.body.should have_json("/view")
    end
  end
end
