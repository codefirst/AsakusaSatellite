require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require '<%= file_name %>_filter'

describe <%= class_name %>Filter do
  before do
    @filter = <%= class_name %>Filter.new({})
  end

  it 'enables process' do
    @filter.process("test").should == "test"
  end
end
