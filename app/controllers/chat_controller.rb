# -*- encoding: utf-8 -*-
class ChatController < ApplicationController
  include ChatHelper
  include RoomHelper
  can_edit_on_the_spot

  PageSize = 20

  def index
    @rooms = Room.all_live(current_user)
  end

  def prev
    @message = params[:id]!="undefined" && Message.find(params[:id])
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

    unless @message.room.accessible?(current_user)
      flash[:error] = t(:error_room_deleted)
      redirect_to :controller => 'chat'
      return
    end

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
      @messages = Message.where("room_id" => @room.id).order_by(:_id.desc).limit(PageSize).to_a
      @title = @room.title
      call_hook(:in_chatroom_controller, :controller => self)
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
        @room.update_attributes!(:updated_at => Time.now)
        if request[:fileupload]
          message = Message.attach(current_user, @room, params)
        else
          message = Message.make(current_user, @room, params[:message])
        end
        publish_message(:create, message, message.room)
      end
    end
    redirect_to :controller => 'chat', :action => 'room', :id => params[:room_id]
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
