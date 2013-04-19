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

class DummyLogger
  def initialize
    @log = []
  end
  def error(log)
    @log.push(log)
  end
  attr_reader :log
end

describe AsakusaSatellite::Hook::Listener do
  describe "call hook" do
    context "apply hook" do
      subject { TestController.new.call_hook(:foo, {:message => 'message'}) }
      it { should =~ /test1 message/ }
      it { should =~ /test2 message/ }
    end

    context "log error" do
      before {
        class TestListener3 < AsakusaSatellite::Hook::Listener
          def foo(context)
            raise "some error happens"
          end
        end
        Rails.logger = DummyLogger.new
      }
      it "logs error" do
        expect { TestController.new.call_hook(:foo, {:message => 'message'}) }.
          to change{ Rails.logger.log.length }.from(0).to(1)
      end
    end
  end
end
