# -*- coding: utf-8 -*-
class ChatController < ApplicationController
  include ChatHelper
  can_edit_on_the_spot

  PageSize = 20

  def index
    @rooms = Room.all_live
  end

  def prev
    @message = Message.find params[:id]
    @messages = if @message then
                  @message.prev( params[:offset] || 20 )
                else
                  []
                end

    render :action => :messages, :layout => false
  end

  def next
    @message = Message.find params[:id]
    @messages = @message.next( params[:offset] || 20 )

    render :action => :messages, :layout => false
  end

  def show
    @id      = params[:id]
    @message = Message.find @id

    @prev_size = int(params[:prev], 5)
    @next_size = int(params[:next], 5)

    @prev_options = [0,1,5,10,15,20,@prev_size].sort.uniq
    @next_options = [0,1,5,10,15,20,@next_size].sort.uniq

    @room = @message.room
    @prev = @message.prev(@prev_size)
    @next = @message.next(@next_size)
  end

  def room
    if request.post?
      if current_user.nil?
        redirect_to :controller => 'chat'
        return
      else 
        @room = Room.new(:title => params[:room][:title], :user => current_user, :updated_at => Time.now)
        if @room.save
          redirect_to :action => 'room', :id => @room.id
        else
          flash[:error] = t(:error_room_cannot_create)
          redirect_to :action => 'create'
          return
        end
      end
    end
    @room ||= Room.find(params[:id])

    if @room then
      if @room.deleted 
        flash[:error] = t(:error_room_deleted)
        redirect_to :action => 'index'
        return
      end
      @messages = Message.select('id, room.id, user.id, body') do |record|
        record.created_at >= Time.now.beginning_of_day and record.room == @room
      end.sort([{:key => "created_at", :order => :desc}], :limit => PageSize)
    else
      render :file=>"#{RAILS_ROOT}/public/404.html", :status=>'404 Not Found'
    end
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

  def create
    redirect_to :controller => 'chat' if current_user.nil?
  end

  def update_attribute_on_the_spot
    room = Room.find(params[:id].split('__')[-1].to_i)
    unless request.post? and  logged?
      render :text => room.title
      return
    end
    unless params[:value].blank?
      raise Error unless room.user == current_user
      room.title = params[:value]
      room.save
    end
    render :text => room.title
  end

  def update_message_on_the_spot
    message = Message.find(params[:id])
    unless request.post? and  logged? and current_user.id == message.user.id
      render :text => message.body
      return
    end
    update_message( message.id,  params[:value])
    render :text => message.body
  end

  private
  def int(s, default)
    if s == nil || s.empty? then
      default
    else
      s.to_i
    end
  end
end
