# -*- encoding: utf-8 -*-
class RoomController < ApplicationController
  include RoomHelper
  before_filter :reject_unless_logged_in

  def create
    if request.post?
      room = Room.new(:title => params[:room][:title],
                      :user => current_user,
                      :updated_at => Time.now,
                      :deleted => false,
                      :is_public => true?(params[:room][:is_public]))
      if room.save
        redirect_to :controller => :chat, :action => 'room', :id => room.id
      else
        flash[:error] = t(:error_room_cannot_create)
        redirect_to :action => 'create'
      end
    end
  end

  def delete
    if request.post?
      case Room.delete(params[:id], current_user)
      when :error_room_not_found then flash[:error] = t(:error_room_deleted)
      when :error_on_save        then flash[:error] = t(:error_on_save)
      end
    end

    redirect_to :controller => 'chat', :action => 'index'
  end

  def configure
    unless request.post?
      @id      = params[:id]
      @plugins = AsakusaSatellite::Config.rooms
      @room = Room.where(:_id => @id).first
      @members = @room.members.uniq
      return
    end

    members = (params[:room][:members] || []).map do |_, user_name|
      User.find_or_create_by(:screen_name => user_name)
    end
    data = {
      :title    => params[:room][:title],
      :nickname => params[:room][:nickname],
      :members  => members
    }
    case room = Room.configure(params[:id], current_user, data)
    when Room
      expire_fragment [:roominfo, room.id, true]
      expire_fragment [:roominfo, room.id, false]
    when :error_room_not_found then flash[:errors] = t(:error_room_deleted)
    when :error_on_save        then flash[:errors] = t(:error_on_save)
    end

    redirect_to :action => 'configure'
  end

  private
  def reject_unless_logged_in
    redirect_to :controller => 'chat' if current_user.nil?
  end

  def true?(x)
    not ['0', false, nil].include?(x)
  end

end
