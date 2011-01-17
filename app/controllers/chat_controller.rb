class ChatController < ApplicationController
  def tweet
    @tweets = Tweet.all
  end

  def index
    @rooms = Room.all
  end

  def room
    if request.post?
      @room = Room.new(:title => params[:room][:title])
      if @room.save
        redirect_to :action => 'room', :id => @room.id
      else
        # TODO: error handling
      end
    end
    @room ||= Room.find(params[:id])
    @messages = Message.select('id, room.id, user.id, body') do |record|
      record.created_at >= Time.now.beginning_of_day and record.room == @room
    end
  end

  def message
    if request.post?
      room = Room.find(params[:room_id])
      @message = Message.new(:room => room, :body => params[:message])
      unless @message.save
        # TODO: error handling
      end
    end
    redirect_to :action => 'room', :id => params[:room_id]
  end
end
