class ChatController < ApplicationController
  def tweet
    @tweets = Tweet.all
  end

  def room
    if request.post?
      room = Room.find(params[:room_id])
      @message = Message.new(:room => room, :body => params[:message])
      unless @message.save
        # TODO: error handling
      end
    end
    @messages = Message.select('id, room.id, user.id, body') do |record|
      record.created_at >= Time.now.beginning_of_day
    end
  end
end
