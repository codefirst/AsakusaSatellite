# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require 'view_hook'

class Dummy
  def image_path(_)
    "image-path"
  end
end

describe AsakusaSatellite::Hook::RedmineTicketLink do
  before do
    config = OpenStruct.new({ :roots => 'http://redmine.example.com/a/'})
    @hook = AsakusaSatellite::Hook::RedmineTicketLink.new config
  end

  describe "message buttons" do
    subject { @hook.message_buttons(:message => Message.new(:body=>"hi", :user=>User.new),
                                    :permlink => 'http://example.com/001',
                                    :self => Dummy.new) }
    it { should have_xml "/a[contains(@href, 'http://redmine.example.com/a/')]" }
    it { should have_xml "//img[@src='image-path']" }
  end
end
