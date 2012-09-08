require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require 'emoji_filter'

describe EmojiFilter do
  before do
    @filter = EmojiFilter.new({})
  end

  describe "non emoji" do
    subject {
      @filter.process("test")
    }

    it { should == "test" }
  end

  describe "emoji" do
    subject {
      ENV['AS_EMOJI_URL_ROOT'] = 'http://example.com/emoji'
      @filter.process(":sushi:")
    }

    it { should == %(<img src="http://example.com/emoji/sushi.png" width="16"/>) }
  end

  describe "emoji with tailing-slash" do
    subject {
      ENV['AS_EMOJI_URL_ROOT'] = 'http://example.com/emoji/'
      @filter.process(":sushi:")
    }

    it { should == %(<img src="http://example.com/emoji/sushi.png" width="16"/>) }
  end


end
