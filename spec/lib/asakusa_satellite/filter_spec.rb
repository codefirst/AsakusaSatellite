require File.dirname(__FILE__) + '/../../spec_helper'

class TestFilter < AsakusaSatellite::Filter::Base
  def process(text, opts={})
    text.gsub('foo','bar')
  end
end

describe AsakusaSatellite::Filter do
  make = lambda do|text|
    @room    = Room.new
    @message = Message.new(:body => text)
    AsakusaSatellite::Filter.process(@message, @room)
  end

  before :all do
    AsakusaSatellite::Filter.initialize!([{'name' => 'test_filter'}])
    AsakusaSatellite::Filter.add_filter TestFilter,{}
  end

  before  do
    CGI.stub(:escapeHTML){|x| x }
  end

  describe 'filter text' do
    subject { make['foos <br/> foo'] }
    it { should == 'bars <br/> bar' }
  end

  describe 'not filter tag' do
    subject { make['<foo>text</foo>'] }
    it { should == '<foo>text</foo>' }
  end

  describe 'tag content' do
    subject { make['<div>foo</div>'] }
    it { should == '<div>foo</div>' }
  end
end


