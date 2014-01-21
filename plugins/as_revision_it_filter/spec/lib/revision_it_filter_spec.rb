require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'revision_it_filter'

describe RevisionItFilter do
  before do
    @filter = RevisionItFilter.new({})
  end

  it 'enables process' do
    @filter.process("test").should == "test"
  end
end
