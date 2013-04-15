require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'global_js_css_listener'

describe GlobalJsCssListener do
  before do
    @listener = GlobalJsCssListener.new({})
    GlobalJsCssFile.create(:type => "javascript", :url => "http://www.example.com/foo.js")
    GlobalJsCssFile.create(:type => "css", :url => "http://www.example.com/bar.css")
  end

  describe "footer" do
    subject {
      @listener.global_footer({})
    }
    it { should == "<script src='http://www.example.com/foo.js' type='text/javascript'></script>" }
  end

  describe "header" do
    subject {
      @listener.global_header({})
    }
    it { should == "<link href='http://www.example.com/bar.css' media='screen' rel='stylesheet' type='text/css'></link>" }
  end

  after do
    GlobalJsCssFile.delete_all
  end

end

