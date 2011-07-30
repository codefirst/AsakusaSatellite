# -*- coding: utf-8 -*-
class ChatController < ApplicationController
  include ChatHelper
  include RoomHelper
  can_edit_on_the_spot

  PageSize = 20

  def index
    public_rooms = Room.where(:is_public => true, :deleted => false).to_a
    private_rooms = Room.where(:is_public => false, :deleted => false).select do |room|
      room.members.any? {|user| user.id == session[:current_user_id]}
    end
    own_rooms = Room.where('user.id' => session[:current_user_id]).to_a
    @rooms = public_rooms + private_rooms
    own_rooms.each do |room|
      @rooms << room if @rooms.all? {|r| r.id != room.id}
    end
  end

  def prev
    @message = Message.find(params[:id])
    @messages = if @message then
                  @message.prev( params[:offset] || 20 )
                else
                  []
                end

    render :action => :messages, :layout => false
  end

  def next
    @message = Message.find(params[:id])
    @messages = @message.next(params[:offset] || 20)

    render :action => :messages, :layout => false
  end

  def show
    @id      = params[:id]
    @message = Message.where(:_id => @id).first

    @prev_size = int(params[:prev], 5)
    @next_size = int(params[:next], 5)

    @prev_options = [0,1,5,10,15,20,@prev_size].sort.uniq
    @next_options = [0,1,5,10,15,20,@next_size].sort.uniq

    @room = @message.room
    @prev = @message.prev(@prev_size)
    @next = @message.next(@next_size)
  end

  def room
    find_room(params[:id], :not_auth=>true) do
      @messages = Message.where("room._id" => @room.id).order_by(:created_at.desc).limit(PageSize)
      @title = @room.title
    end
  end

  def message
    unless logged?
      flash[:error] = t(:error_message_user_not_login_yet)
      redirect_to :controller => 'chat'
      return
    end
    if request.post? then
      find_room(params[:room_id]) do
        if request[:fileupload]
          create_attach(params[:room_id], params)
        else
          create_message(params[:room_id], params[:message])
        end
        @room.update_attributes!(:updated_at => Time.now)
      end
    end
    redirect_to :controller => 'chat', :action => 'room', :id => params[:room_id]
  end

  def update_message_on_the_spot
    message = Message.find(params[:id])
    if request.post? and  logged? and current_user.id == message.user.id
      update_message( message.id,  params[:value])
    end
    render :text => message.body
  end

  private
  def int(s, default)
    if s.blank? then
      default
    else
      s.to_i
    end
  end
end
