# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe AsakusaSatellite::Hook::Listener do
  it "Listenerを登録すると call_hook で呼び出せる" do
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
    TestController.new.call_hook(:foo, {:message => 'message'}).should =~ /test1 message/
    TestController.new.call_hook(:foo, {:message => 'message'}).should =~ /test2 message/
  end
end
