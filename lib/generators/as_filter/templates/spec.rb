require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require '<%= file_name %>_filter'

describe AsakusaSatellite::Filter::<%= class_name %>Filter do
  before do
    @filter = AsakusaSatellite::Filter::<%= class_name %>Filter.new({})
  end

  it 'enables process' do
   expect(@filter.process("test")).to eq "test"
  end
end
