# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'auto_link'

describe AsakusaSatellite::Filter::AutoLink do
  before do
    @filter = AsakusaSatellite::Filter::AutoLink.new({})
  end

  it 'URLにリンクを貼る' do
    @filter.process('http://example.com').should have_xml("//a[@href='http://example.com']")
  end

  it "httpsについても動作する" do
    @filter.process('https://example.com').should have_xml("//a[@href='https://example.com']")
  end

  it "前後に文字があっても動作する" do
    @filter.process('<div>ほげhttp://example.comほげ</div>').should have_xml("//a[@href='http://example.com']")
    @filter.process('<div>ほげhttp://example.com/abcほげ</div>').should have_xml("//a[@href='http://example.com/abc']")
  end

  describe 'twitpicを展開する' do
    subject { @filter.process('http://twitpic.com/3gy2dn') }
    it { should have_xml("//a[@href='http://twitpic.com/3gy2dn']") }
    it { should have_xml("//img[@src='http://twitpic.com/show/thumb/3gy2dn']") }
  end
end
