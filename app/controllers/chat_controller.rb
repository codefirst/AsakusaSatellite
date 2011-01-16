class ChatController < ApplicationController
  def tweet
    puts Tweet
    @tweets = Tweet.all
  end

end
