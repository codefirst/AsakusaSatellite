require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'revision_it_filter'

describe AsakusaSatellite::Filter::RevisionItFilter do
  before {
    @filter = AsakusaSatellite::Filter::RevisionItFilter.new({})
  }

  context 'with normal text' do
    before do
      @filter.stub!(:open).and_raise('error')
    end

    subject {
      @filter.process("test")
    }

    it { should == "test" }
  end

  context 'valid hash' do
    before do
      io = StringIO.new "[[hash html]]"
      @filter.stub!(:open).with("http://revision-it.herokuapp.com/hash/x123456") { io }
    end

    subject { @filter.process("rev:x123456") }
    it { should == "[[hash html]]" }
  end

  context 'invalid hash' do
    before do
      @filter.stub!(:open).and_raise('error')
    end

    subject {
      @filter.process("rev:1232cg32ccp032")
    }
    it { should == 'rev:1232cg32ccp032' }
  end
end
