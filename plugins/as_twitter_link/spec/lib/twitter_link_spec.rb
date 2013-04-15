require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'twitter_link'

describe AsakusaSatellite::Filter::TwitterLink do
  before do
    @filter = AsakusaSatellite::Filter::TwitterLink.new({})
  end

  describe "non twitter id" do
    subject {
      @filter.process("test")
    }

    it { should == "test" }
  end

  describe "twitter id" do
    subject {
      @filter.process("@mzp")
    }

    it { should == "<a href=\"http://twitter.com/mzp\" target=\"_blank\">@mzp</a>" }
  end

end
