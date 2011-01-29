# -*- coding: utf-8 -*-
require 'spec_helper'
require 'asakusa_satellite/filter/redmine_ticket_link'

describe AsakusaSatellite::Filter::RedmineTicketLink do
  before do
    @filter = AsakusaSatellite::Filter::RedmineTicketLink.new(OpenStruct.new({ :roots => 'http://redmine.example.com/a'}))
  end

  it 'チケット番号にリンクを貼る' do
    @filter.process('#223').should == '<a href="http://redmine.example.com/a/issues/223">#223</a>'
  end
end
