# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require 'redmine_ticket_link'

describe AsakusaSatellite::Filter::RedmineTicketLink do
  it 'チケット番号にリンクを貼る' do
    config = OpenStruct.new({ :roots => 'http://redmine.example.com/a/'})
    @filter = AsakusaSatellite::Filter::RedmineTicketLink.new(config)
    @filter.process('#223').should == '<a target="_blank" href="http://redmine.example.com/a/issues/223">#223</a>'
    @filter.process('foo #223').should == 'foo <a target="_blank" href="http://redmine.example.com/a/issues/223">#223</a>'
  end

  it 'API keylが指定されてる場合は、タイトルを取得する' do
    json = <<'JSON'
{"issue":{"spent_hours":0.0,"status":{"name":"\u65b0\u898f","id":1},"created_on":"2011/02/14 21:25:48 +0900","start_date":"2011/02/14","subject":"Redmine\u30d7\u30e9\u30b0\u30a4\u30f3\u3092\u30bf\u30a4\u30c8\u30eb\u3082\u53d6\u308c\u308b\u3088\u3046\u306b\u3059\u308b","assigned_to":{"name":"Mizuno Hiroki","id":9},"fixed_version":{"name":"V0.2","id":15},"description":"http://d.hatena.ne.jp/ka-ka_xyz/20100221/1266755189","done_ratio":0,"updated_on":"2011/02/14 21:27:00 +0900","project":{"name":"AsakusaSatellite","id":33},"author":{"name":"Mizuno Hiroki","id":9},"category":{"name":"plugin","id":18},"id":380,"priority":{"name":"\u901a\u5e38","id":4},"tracker":{"name":"\u6a5f\u80fd","id":2}}}
JSON
    io = StringIO.new json

    config = OpenStruct.new({ :roots => 'http://redmine.example.com/a/', :api_key=> 'hoge'})
    @filter = AsakusaSatellite::Filter::RedmineTicketLink.new(config)
    @filter.stub!(:open).with('http://redmine.example.com/a/issues/380.json?key=hoge').and_yield(io)
    @filter.process('#380').should ==
      '<a target="_blank" href="http://redmine.example.com/a/issues/380">#380 Redmineプラグインをタイトルも取れるようにする</a>'
  end
end
