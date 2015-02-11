require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'revision_it_filter'

describe AsakusaSatellite::Filter::RevisionItFilter do
  before {
    @filter = AsakusaSatellite::Filter::RevisionItFilter.new({})
  }

  context 'with normal text' do
    before do
      allow(@filter).to receive(:open).and_raise('error')
    end

    subject {
      @filter.process("test")
    }

    it { should == "test" }
  end

  context 'valid hash' do
    before do
      io = StringIO.new({ 'status' => 'ok',
                          'revision' => {
                             'url' => "http://example.com",
                             'hash_code' => "1234567890",
                             'log' => "foo\nbar" }
                        }.to_json)
      allow(@filter).to receive(:open).with("http://revision-it.herokuapp.com/hash/x123456.json") { io }
    end

    subject { @filter.process("rev:x123456") }
    it { should == %(<a href="http://example.com" target="_blank">123456 foo</a>) }
  end

  context 'invalid hash' do
    before do
      allow(@filter).to receive(:open).and_raise('error')
    end

    subject {
      @filter.process("rev:1232cg32ccp032")
    }
    it { should == 'rev:1232cg32ccp032' }
  end
end
