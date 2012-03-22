# -*- coding: utf-8 -*-
class RoomController < ApplicationController
  include RoomHelper

  # falseにするリスト
  def true?(x)
    not ['0', false, nil].include?(x)
  end

  def create
    if current_user.nil?
      redirect_to :controller => 'chat'
    elsif request.post?

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
    @id = params[:id]

    if request.post?
      find_room(@id) do
        @room.deleted = true
        @room.save!
        redirect_to :controller => 'chat', :action => 'index'
      end
    else
      redirect_to :controller => 'chat', :action => 'index'
    end
  end

  def configure
    @id      = params[:id]
    @plugins = AsakusaSatellite::Config.rooms
    find_room(@id) do
      if request.post? then
        @room.title = params[:room][:title] unless params[:room][:title].blank?
        unless params[:room][:members].blank?
          @room.members = params[:room][:members].map do |_, user_name|
            user = User.where(:screen_name => user_name).first
            if user.nil? then
              []
            else
              user
            end
          end.flatten
        end
        @room.save
        expire_fragment :controller => 'chat', :action => 'room', :id => @room.id
        redirect_to :action => 'configure'
      end
      @members = @room.members.uniq
    end
  end

  private
  def include_member(room, user)
    return false if room.nil?
    return false if room.members.nil?
    room.members.each do |member|
      return true if member.id.to_s == user.id.to_s
    end
    false
  end

end
