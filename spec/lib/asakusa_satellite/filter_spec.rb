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

  describe "passing plain text" do
    describe 'filter text' do
      subject { make['foos & <br/> foo'] }
      it { should == 'bars &amp; &lt;br/&gt; bar' }
    end

    describe 'escape string' do
      subject { make['& < > "'] }
      it { should == "&amp; &lt; &gt; &quot;" }
    end

    describe 'apos string' do
      subject { make["'"] }
      it { should == "'" }
    end
  end

  describe "passing tags" do
    before do
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

    describe 'escape string' do
      subject { make['<div>&amp;</div>'] }
      it { should == '<div>&amp;</div>' }
    end

    describe 'apos string' do
      subject { make["<div>'</div>"] }
      it { should == "<div>'</div>" }
    end

    describe 'apos string' do
      subject { make["<div>'<a href=\"baz/'\">baz/'</a></div>"] }
      it { should == "<div>'<a href=\'baz/&apos;'>baz/'</a></div>" }
    end

#    describe 'not-wellformed' do
#      subject { make["<input disable>"] }
#      it { should == "<input disable>" }
#    end

    describe 'script' do
      subject { make["<script/>"] }
      it { should == "<script></script>" }
    end

    describe 'iframe' do
      subject { make["<iframe/>"] }
      it { should == "<iframe></iframe>" }
    end

    describe 'div' do
      subject { make["<div/>"] }
      it { should == "<div/>" }
    end
  end

end


