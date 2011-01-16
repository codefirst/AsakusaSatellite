require 'spec_helper'

describe Member do
  # ActiveGroonga の評価のため非常に基本的なspec
  describe "メッセージを登録したら" do
    before do
      @body = 'これは本文です'
      @message = Message.new(:body => @body)
      @message.save
    end

    it "本文を取得できる(trivial)" do
      @message.body.should = @body
    end
  end
end
