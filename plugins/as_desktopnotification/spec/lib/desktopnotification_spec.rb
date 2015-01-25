require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'desktopnotification'

describe DesktopnotificationListener do
  before do
    @listener = DesktopnotificationListener.new({})
    @controller = AccountController.new.view_context.tap do |context|
      context.instance_eval do
        def url_options
          ActionController::Base.default_url_options
        end
      end
    end
  end

  describe "account/index" do
    subject {
      context = {:request => {:controller => "account", :action => "index"}, :controller => @controller}
      @listener.global_footer(context)
    }
    it { should eq '<script src="/plugin/as_desktopnotification/javascript/desktopnotification.js"></script>' +
                   '<script src="/plugin/as_desktopnotification/javascript/desktopnotification_setting.js"></script>' }
  end

  describe "chat/room" do
    subject {
      context = {:request => {:controller => "chat", :action => "room"}, :controller => @controller}
      @listener.global_footer(context)
    }
    it { should eq '<script src="/plugin/as_desktopnotification/javascript/desktopnotification.js"></script>' +
                   '<script src="/plugin/as_desktopnotification/javascript/desktopnotification_notify.js"></script>' }
  end

end
