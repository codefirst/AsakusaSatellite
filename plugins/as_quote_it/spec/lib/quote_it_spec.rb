require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'quote_it'

describe AsakusaSatellite::Filter::QuoteIt do
  context 'not raise' do
    before do
      @filter = AsakusaSatellite::Filter::QuoteIt.new({})
      io = StringIO.new "<a href='http://www.example.com/1.png'>1</a>"

      @filter.stub!(:open).with("https://quoteit.herokuapp.com/clip.html?u=#{CGI.escape 'http://www.example.com/1'}").and_return(io)
    end

    describe "non url" do
      subject {
        @filter.process("test")
      }
      it { should == "test" }
    end

    describe "url" do
      subject {
        @filter.process("http://www.example.com/1")
      }
      it { should == "<a href='http://www.example.com/1.png'>1</a>" }
    end
  end

  context 'raise' do
    before do
      @filter = AsakusaSatellite::Filter::QuoteIt.new({})
      io = StringIO.new "<a href='http://www.example.com/1.png'>1</a>"

      @filter.stub!(:open).and_raise('error')
    end

    describe "non url" do
      subject {
        @filter.process("test")
      }
      it { should == "test" }
    end

    describe "url" do
      subject {
        @filter.process("http://www.example.com/1")
      }
      it { should == '<a target="_blank" href="http://www.example.com/1">http://www.example.com/1</a>'}
    end
  end

end
