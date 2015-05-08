# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe 'patch' do
  describe "active_support_json_encoding" do
    subject { JSON.parse("[#{'🍣'.to_json}]") }
    it { should == ["🍣"] }
  end
end
