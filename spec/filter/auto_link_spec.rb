# -*- coding: utf-8 -*-
require 'spec_helper'
require 'asakusa_satellite/filter/auto_link'

describe AsakusaSatellite::Filter::AutoLink do
  before do
    @filter = AsakusaSatellite::Filter::AutoLink.new({})
  end

  it 'URLにリンクを貼る' do
    @filter.process('http://example.com').should == '<a href="http://example.com">http://example.com</a>'
  end

  it "httpsについても動作する" do
    @filter.process('https://example.com').should == '<a href="https://example.com">https://example.com</a>'
  end

  it "前後に文字があっても動作する" do
    @filter.process('ほげhttp://example.comほげ').should == 'ほげ<a href="http://example.com">http://example.com</a>ほげ'
    @filter.process('ほげhttp://example.com/abcほげ').should == 'ほげ<a href="http://example.com/abc">http://example.com/abc</a>ほげ'
  end
end
