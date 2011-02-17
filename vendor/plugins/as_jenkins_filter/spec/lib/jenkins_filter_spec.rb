require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require 'jenkins_filter'

describe JenkinsFilter do
  before do
    @filter = JenkinsFilter.new({})
  end

  it 'enables process' do
    @filter.process("::test:a:b").should == "a & b"
  end
end
