# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'as_iphone_notifier'

describe AsakusaSatellite::Hook::ASIPhoneNotifier do
  before do
    @hook = AsakusaSatellite::Hook::ASIPhoneNotifier.new({})
  end

  it 'JSONエンコード済み文字列長制限で元の文字列を切る' do
    expect(@hook.strip('test', 3)).to eq 'tes'
    expect(@hook.strip('test', 4)).to eq 'test'
    expect(@hook.strip('test', 5)).to eq 'test'

    expect(@hook.strip('日本語', 3*6-1)).to eq '日本'
    expect(@hook.strip('日本語', 3*6)).to eq '日本語'
    expect(@hook.strip('日本語', 3*6+1)).to eq '日本語'
  end
end

