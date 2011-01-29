class ChatController < ApplicationController
  include ChatHelper
  can_edit_on_the_spot

  def tweet
    @tweets = Tweet.all
  end

  def index
    @rooms = Room.all || []
  end

  def room
    if request.post?
      @room = Room.new(:title => params[:room][:title], :user => current_user)
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
    logger.info params[:fileupload]
    unless logged?
      flash[:error] = t(:error_message_user_not_login_yet)
      redirect_to :controller => 'chat'
      return
    end
    message = nil
    if request.post?
      if request[:fileupload]
        message = params[:filename]
        open("#{RAILS_ROOT}/public/upload/#{request[:filename]}", "wb") do |f|
          f.write(params[:file].read)
        end
      else
        message = params[:message]
      end
      logger.info "+++++++++++"
      logger.info message
      create_message(params[:room_id], message)
    end
    redirect_to :controller => 'chat'
  end

  def update_attribute_on_the_spot
    room = Room.find(params[:id].split('__')[-1].to_i)
    room.title = params[:value]
    room.save
    render :text => room.title
  end

end
