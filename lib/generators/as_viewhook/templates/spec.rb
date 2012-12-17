require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require '<%= file_name %>'

describe <%= class_name %>Listener do
  before do
    @listener = <%= class_name %>Listener.new({})
  end

  it 'enables process' do
    @listener.process("test").should == "test"
  end
end
