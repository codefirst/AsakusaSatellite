# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'view_hook'

class Dummy
  def image_path(_)
    "image-path"
  end
end

describe AsakusaSatellite::Hook::RedmineTicketLink do
  before do
    @hook = AsakusaSatellite::Hook::RedmineTicketLink.new({})
  end

  describe "message buttons" do
    context 'Redmine の URL が / で終わる' do
      subject {
        room = Room.new
        room.yaml = {:redmine_ticket => {
            'root' => 'http://redmine.example.com/foo/',
            'project_name' =>'bar'
          }}
        @hook.message_buttons(:message => Message.new(:body=>"hi", :user=>User.new, :room => room),
          :permlink => 'http://example.com/001',
          :self => Dummy.new) }
      it { should have_xml "/a[contains(@href, 'http://redmine.example.com/foo/projects/bar')]" }
      it { should have_xml "//img[@src='image-path']" }
    end

    context 'Redmine の URL が / で終わらない' do
      subject {
        room = Room.new
        room.yaml = {:redmine_ticket => {
            'root' => 'http://redmine.example.com/foo',
            'project_name' =>'bar'
          }}
        @hook.message_buttons(:message => Message.new(:body=>"hi", :user=>User.new, :room => room),
          :permlink => 'http://example.com/001',
          :self => Dummy.new) }
      it { should have_xml "/a[contains(@href, 'http://redmine.example.com/foo/projects/bar')]" }
      it { should have_xml "//img[@src='image-path']" }
    end
  end
end
