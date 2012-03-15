require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require 'emoticon_filter'

describe EmoticonFilter do
  before do
    @filter = EmoticonFilter.new({})
  end

  it 'enables process' do
    @filter.process("test").should == "test"
  end
end
