# -*- mode:ruby; coding:utf-8 -*-
require 'asakusa_satellite/url_util'

describe AsakusaSatellite::UrlUtil do
  describe 'パラメータ無' do
    subject { AsakusaSatellite::UrlUtil.parse('/Get') }
    its([:name]) { should == :get }
    its([:query]) { should == {} }
  end

  describe 'パラメータ有' do
    subject { AsakusaSatellite::UrlUtil.parse('/get?a=1&b=2') }
    its([:name]) { should == :get }
    its([:query]) { should == {:a => '1', :b => '2'} }
  end
end
