# -*- coding:utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'
require 'asakusa_satellite/filter/inline_plugin'

class GesoFilter <  AsakusaSatellite::Filter::InlinePlugin
  plugin :geso do|text|
    "#{text}でゲソ"
  end

  plugin :geso2 do|x, y|
    "#{x}と#{y}でゲソ"
  end

  plugin :conf do|x|
    "#{config.hoge}"
  end
end

describe AsakusaSatellite::Filter::InlinePlugin do
  it "プラグイン書式が使える" do
    @filter = GesoFilter.new({})
    @filter.process("::geso:hoge").should == "hogeでゲソ"
  end

  it "複数の引数にも対応する" do
    @filter = GesoFilter.new({})
    @filter.process("::geso2:a:b").should == "aとbでゲソ"
  end

  it "configもあつかえる" do
    @filter = GesoFilter.new(OpenStruct.new({:hoge=>42}))
    @filter.process("::conf:hoge").should == "42"
  end
end
