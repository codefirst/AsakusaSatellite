require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'watage_policy'

describe Watage::WatagePolicy do
  before do
    @policy = Watage::WatagePolicy.new
    allow(RestClient).to receive(:post).and_return('{"source":"http://www.example.com/foo.zip"}')
  end

  describe "upload" do
    subject {
      @policy.upload("foo.zip", nil, nil, nil)
    }
    it { should == "http://www.example.com/foo.zip" }
  end
end
