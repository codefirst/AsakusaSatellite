class ChatController < ApplicationController
  def tweet
    @tweets = Tweet.all
  end

end
