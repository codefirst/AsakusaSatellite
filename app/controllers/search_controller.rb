# -*- encoding: utf-8 -*-
class SearchController < ApplicationController
  include RoomHelper

  def index
    @rooms = search_form
  end

  def search
    if params[:search].blank? or params[:search][:message].blank?
      redirect_to :action => :index
    else
      @query = params[:search][:message]
      @rooms = search_form
      @room_id = params[:room].blank? ? "" : params[:room][:id]
      if @room_id.blank?
        @results = Message.find_by_text :text => @query, :rooms => Room.all_live(current_user)
      else
        find_room(@room_id, :not_auth => true) do
          @results = Message.find_by_text(:text => @query, :rooms => [ @room ])
        end
      end
    end
  end

  private
  def search_form
    Room.all_live(current_user).map {|room| [room.title, room.id]}
  end
end
