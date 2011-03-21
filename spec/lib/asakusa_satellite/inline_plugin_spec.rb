# -*- coding:utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'
require 'asakusa_satellite/filter/inline_plugin'

class GesoFilter <  AsakusaSatellite::Filter::InlinePlugin
  plugin :geso do|a|
    "#{a}でゲソ"
  end

  plugin :geso2 do|x, y|
    "#{x}と#{y}でゲソ"
  end

  plugin :conf do|x|
    "#{config.hoge}"
  end
end

describe AsakusaSatellite::Filter::InlinePlugin do
  before { @filter = GesoFilter.new(OpenStruct.new({:hoge=>42})) }
  describe "引数なし" do
    subject { @filter.process("::geso:a") }
    it { should == "aでゲソ" }
  end

  describe "引数あり" do
    subject { @filter.process("::geso2:a:b") }
    it { should == "aとbでゲソ" }
  end

  describe "設定あり" do
    subject { @filter.process("::conf:hoge") }
    it { should == "42" }
  end
end
