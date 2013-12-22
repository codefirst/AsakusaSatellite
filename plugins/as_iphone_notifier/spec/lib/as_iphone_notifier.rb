# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'as_iphone_notifier'

describe AsakusaSatellite::Hook::ASIPhoneNotifier do
  before do
    @hook = AsakusaSatellite::Hook::ASIPhoneNotifier.new({})
  end

  it 'JSONエンコード済み文字列長制限で元の文字列を切る' do
    @hook.strip('test', 3).should == 'tes'
    @hook.strip('test', 4).should == 'test'
    @hook.strip('test', 5).should == 'test'
    
    @hook.strip('日本語', 3*6-1).should == '日本'
    @hook.strip('日本語', 3*6).should == '日本語'
    @hook.strip('日本語', 3*6+1).should == '日本語'
  end
end

