# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

class TestListener1 < AsakusaSatellite::Hook::Listener
  def foo(context)
    "test1 "  + context[:message]
  end
end
class TestListener2 < AsakusaSatellite::Hook::Listener
  def foo(context)
    "test2 "  + context[:message]
  end
end
class TestController
  include AsakusaSatellite::Hook::Helper
end

describe AsakusaSatellite::Hook::Listener do
  describe "call hook" do
    subject { TestController.new.call_hook(:foo, {:message => 'message'}) }
    it { should =~ /test1 message/ }
    it { should =~ /test2 message/ }
  end
end
