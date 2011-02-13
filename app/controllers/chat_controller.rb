# -*- coding: undecided -*-
class ChatController < ApplicationController
  include ChatHelper
  can_edit_on_the_spot

  PageSize = 20

  def index
    @rooms = Room.all_live
  end

  def show
    @id      = params[:id]
    @window  = params[:c].to_i || 5
    @message = Message.find @id
    @room    = @message.room

    prev = Message.select('id, room.id, user.id, body') do |record|
      record.id < @message.id
    end.sort([{:key => "created_at", :order => :desc}], :limit => @window).to_a

    next_ = Message.select('id, room.id, user.id, body') do |record|
      record.id > @message.id
    end.sort([{:key => "created_at", :order => :desc}], :limit => @window).to_a

    @messages = next_ + [ @message ] + prev
  end

  def room
    if request.post?
      @room = Room.new(:title => params[:room][:title], :user => current_user, :updated_at => Time.now)
      if @room.save
        redirect_to :action => 'room', :id => @room.id
      else
        flash[:error] = t(:error_room_cannot_create)
        redirect_to :action => 'create'
        return
      end
    end
    @room ||= Room.find(params[:id])
    @messages = Message.select('id, room.id, user.id, body') do |record|
      record.created_at >= Time.now.beginning_of_day and record.room == @room
    end.sort([{:key => "created_at", :order => :desc}], :limit => PageSize)
  end

  def message
    unless logged?
      flash[:error] = t(:error_message_user_not_login_yet)
      redirect_to :controller => 'chat'
      return
    end
    if request.post?
      if Room.find(params[:room_id]).nil?
        flash[:error] = t(:error_message_room_not_found)
        redirect_to :controller => 'chat'
      end 
      if request[:fileupload]
        message = create_message(params[:room_id], "", :force => true)
        @attachment = Attachment.create_and_save_file(params[:filename], params[:file], params[:mimetype], message)
      else
        message_body = params[:message]
        create_message(params[:room_id], message_body)
      end
      room = Room.find(params[:room_id])
      room.updated_at = Time.now
      room.save
    end
    redirect_to :controller => 'chat'
  end

  def update_attribute_on_the_spot
    room = Room.find(params[:id].split('__')[-1].to_i)
    unless params[:value].blank?
      raise Error unless room.user == current_user
      room.title = params[:value]
      room.save
    end
    render :text => room.title
  end

  def update_message_on_the_spot
    message = Message.find(params[:id])
    message.body = params[:value]
    message.save
    render :text => message.body 
  end
end
