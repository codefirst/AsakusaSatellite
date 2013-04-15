require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'desktopnotification'

describe DesktopnotificationListener do
  before do
    @listener = DesktopnotificationListener.new({})
  end

  describe "account/index" do
    subject {
      context = {:request => {:controller => "account", :action => "index"}}
      @listener.global_footer(context)
    }
    it { should =~ /<script>.+<\/script>/m }
  end

  describe "chat/room" do
    subject {
      context = {:request => {:controller => "chat", :action => "room"}}
      @listener.global_footer(context)
    }
    it { should =~ /<script>.+<\/script>/m }
  end

end
