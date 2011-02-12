require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require 'code_highlight_filter'

describe CodeHighlightFilter do
  before do
    @filter = CodeHighlightFilter.new({})
  end

  it 'enables process' do
    @filter.process("test").should == "test"
  end
end
