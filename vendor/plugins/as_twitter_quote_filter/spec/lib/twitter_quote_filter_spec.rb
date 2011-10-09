require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require 'twitter_quote_filter'

describe TwitterQuoteFilter do
  before do
    @filter = TwitterQuoteFilter.new({})
  end

  it 'enables process' do
    @filter.process("test").should == "test"
  end
end
