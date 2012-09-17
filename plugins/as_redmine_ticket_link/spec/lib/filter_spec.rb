# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'

describe AsakusaSatellite::Filter::RedmineTicketLink do
  describe "API Keyなし" do
    context "Redmine の URL の最後が /" do
      before do
        @config = { :room =>
          OpenStruct.new(:yaml => {
              :redmine_ticket => { 'root' => 'http://redmine.example.com/a/'
              }})
        }
        @filter = AsakusaSatellite::Filter::RedmineTicketLink.new({})
      end

      subject {
        @filter.process("foo #223", @config)
      }
      it {
        should == 'foo <a target="_blank" href="http://redmine.example.com/a/issues/223">#223</a>'
      }
    end

    context "Redmine の URL の最後が / じゃない" do
      before do
        @config = { :room =>
          OpenStruct.new(:yaml => {
              :redmine_ticket => { 'root' => 'http://redmine.example.com/a'
              }})
        }
        @filter = AsakusaSatellite::Filter::RedmineTicketLink.new({})
      end

      subject {
        @filter.process("foo #223", @config)
      }
      it {
        should == 'foo <a target="_blank" href="http://redmine.example.com/a/issues/223">#223</a>'
      }
    end
  end

  describe "API keyあり" do
    before do
      @config = { :room =>
        OpenStruct.new(:yaml => {
                         :redmine_ticket => {
                           'root' => 'http://redmine.example.com/a/',
                           'api_key' => 'hoge'
                         }})}
      @filter = AsakusaSatellite::Filter::RedmineTicketLink.new({})

      json = <<'JSON'
{"issue":{"spent_hours":0.0,"status":{"name":"\u65b0\u898f","id":1},"created_on":"2011/02/14 21:25:48 +0900","start_date":"2011/02/14","subject":"Redmine\u30d7\u30e9\u30b0\u30a4\u30f3\u3092\u30bf\u30a4\u30c8\u30eb\u3082\u53d6\u308c\u308b\u3088\u3046\u306b\u3059\u308b","assigned_to":{"name":"Mizuno Hiroki","id":9},"fixed_version":{"name":"V0.2","id":15},"description":"http://d.hatena.ne.jp/ka-ka_xyz/20100221/1266755189","done_ratio":0,"updated_on":"2011/02/14 21:27:00 +0900","project":{"name":"AsakusaSatellite","id":33},"author":{"name":"Mizuno Hiroki","id":9},"category":{"name":"plugin","id":18},"id":380,"priority":{"name":"\u901a\u5e38","id":4},"tracker":{"name":"\u6a5f\u80fd","id":2}}}
JSON
      io = StringIO.new json

      @filter.stub!(:open).with('http://redmine.example.com/a/issues/380.json?key=hoge').and_yield(io)
    end

    subject {
      @filter.process('#380', @config)
    }

    it {
      should == '<a target="_blank" href="http://redmine.example.com/a/issues/380">#380 Redmineプラグインをタイトルも取れるようにする</a>'}
  end
end
