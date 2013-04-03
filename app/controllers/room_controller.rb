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
        @room.title = params[:room][:title]
        @room.nickname = params[:room][:nickname]
        unless params[:room][:members].blank?
          @room.members = params[:room][:members].map do |_, user_name|
            user = User.where(:screen_name => user_name).first
            if user.nil? then
              User.new(:screen_name => user_name,
                       :profile_image_url => "data:image/gif;base64,R0lGODlhEAAQAMQfAFWApnCexR4xU1SApaJ3SlB5oSg9ZrOVcy1HcURok/Lo3iM2XO/i1lJ8o2eVu011ncmbdSc8Zc6lg4212DZTgC5Hcmh3f8OUaDhWg7F2RYlhMunXxqrQ8n6s1f///////yH5BAEAAB8ALAAAAAAQABAAAAVz4CeOXumNKOpprHampAZltAt/q0Tvdrpmm+Am01MRGJpgkvBSXRSHYPTSJFkuws0FU8UBOJiLeAtuer6dDmaN6Uw4iNeZk653HIFORD7gFOhpARwGHQJ8foAdgoSGJA1/HJGRC40qHg8JGBQVe10kJiUpIQA7")
            else
              user
            end
          end.flatten
        end
        flash[:errors] = format_error_messages(@room) unless @room.save
        expire_fragment [:roominfo, @room.id, true]
        expire_fragment [:roominfo, @room.id, false]
        redirect_to :action => 'configure'
      end
      @members = @room.members.uniq
      @room.members = @members
    end
  end

  private
  def reject_unless_logged_in
    redirect_to :controller => 'chat' if current_user.nil?
  end

  def include_member(room, user)
    return false if room.nil?
    return false if room.members.nil?
    room.members.each do |member|
      return true if member.id.to_s == user.id.to_s
    end
    false
  end

  def true?(x)
    not ['0', false, nil].include?(x)
  end

end
