require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'emoji_filter'

describe EmojiFilter do
  before do
    @filter = EmojiFilter.new({})
    ENV['AS_EMOJI_URL_ROOT'] = 'http://example.com/emoji'
  end

  describe "non emoji" do
    subject {
      @filter.process("test")
    }

    it { should == "test" }
  end

  describe "non emoji with spaces" do
    subject {
      @filter.process(":t est:")
    }

    it { should == ":t est:" }
  end

  describe "emoji" do
    subject {
      @filter.process(":sushi:")
    }

    it { should == %(<img src="http://example.com/emoji/sushi.png" style="width:16px" title="sushi" alt="sushi"/>) }
  end

  describe "emoji with tailing-slash" do
    subject {
      @filter.process(":sushi:")
    }

    it { should == %(<img src="http://example.com/emoji/sushi.png" style="width:16px" title="sushi" alt="sushi"/>) }
  end

  describe "non-existent emoji" do
    subject {
      @filter.process(":asakusasatellite:")
    }

    it { should == ":asakusasatellite:" }
  end
end
