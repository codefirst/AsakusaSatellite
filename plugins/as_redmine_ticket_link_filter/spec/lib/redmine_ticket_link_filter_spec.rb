# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'

describe AsakusaSatellite::Filter::RedmineTicketLinkFilter do
  describe "API Keyなし" do
    context "Redmine の URL の最後が /" do
      before do
        @config = { :room =>
          OpenStruct.new(:yaml => {
              :redmine_ticket => { 'root' => 'http://redmine.example.com/a/'
              }})
        }
        @filter = AsakusaSatellite::Filter::RedmineTicketLinkFilter.new({})
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
        @filter = AsakusaSatellite::Filter::RedmineTicketLinkFilter.new({})
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
      @filter = AsakusaSatellite::Filter::RedmineTicketLinkFilter.new({})

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

  describe "タイトルに '&' が含まれる" do
    before do
      @config = { :room =>
        OpenStruct.new(:yaml => {
                         :redmine_ticket => {
                           'root' => 'http://redmine.example.com/a/',
                           'api_key' => 'hoge'
                         }})}
      @filter = AsakusaSatellite::Filter::RedmineTicketLinkFilter.new({})

      json = <<'JSON'
{"issue":{"fixed_version":{"id":39,"name":"v0.8.1"},"author":{"id":6,"name":"\u4e0b\u6751 \u7fd4"},"id":1334,"description":"\u30a8\u30b9\u30b1\u30fc\u30d7\u6f0f\u308c\r\n\r\nhttp://asakusa-satellite.org/message?id=5074b59973aef3000200000c","updated_on":"2012-10-15T02:40:34Z","start_date":"2012-10-10","project":{"id":33,"name":"AsakusaSatellite"},"subject":"redmine_ticket \u30d7\u30e9\u30b0\u30a4\u30f3\u3067\u30c1\u30b1\u30c3\u30c8\u3092\u4f5c\u308b\u3068\u304d\u3001\u672c\u6587\u306b & \u304c\u3042\u308b\u3068\u305d\u3053\u3067\u30d1\u30e9\u30e1\u30fc\u30bf\u304c\u5207\u308c\u3061\u3083\u3046\u3002","priority":{"id":4,"name":"\u901a\u5e38"},"assigned_to":{"id":6,"name":"\u4e0b\u6751 \u7fd4"},"tracker":{"id":1,"name":"\u6539\u5584\u8981\u671b"},"status":{"id":3,"name":"\u89e3\u6c7a"},"done_ratio":100,"created_on":"2012-10-09T23:42:00Z"}}
JSON
      io = StringIO.new json

      @filter.stub!(:open).with('http://redmine.example.com/a/issues/1334.json?key=hoge').and_yield(io)
    end

    subject {
      @filter.process('#1334', @config)
    }

    it {
      should == '<a target="_blank" href="http://redmine.example.com/a/issues/1334">#1334 redmine_ticket プラグインでチケットを作るとき、本文に &amp; があるとそこでパラメータが切れちゃう。</a>'}
  end

  describe "例外発生" do
    before do
      @config = { :room =>
        OpenStruct.new(:yaml => {
                         :redmine_ticket => {
                           'root' => 'http://redmine.example.com/a/',
                           'api_key' => 'hoge'
                         }})}
      @filter = AsakusaSatellite::Filter::RedmineTicketLinkFilter.new({})
      @filter.stub!(:open).and_raise("error")
    end

    subject {
      @filter.process('#1334', @config)
    }

    it {
      should == '<a target="_blank" href="http://redmine.example.com/a/issues/1334">#1334</a>'
    }
  end
end


