class ChatController < ApplicationController
  def tweet
    @tweets = Tweet.all
  end

  def room
    if request.post?
      Message.new(:body => params[:message]).save
    end
  end
end
