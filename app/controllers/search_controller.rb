class SearchController < ApplicationController
  def index
    @rooms = _search_form
  end

  def search
    if params[:search].blank? or params[:search][:message].blank?
      redirect_to :action => :index
    end
    @rooms = _search_form
    @query = params[:search][:message]
    @room_id = params[:room].blank? ? "" : params[:room][:id]
    rooms = []
    if @room_id.blank?
      rooms = Room.all_live
    else
      rooms = Room.select do |room|
        [room.id == @room_id, room.deleted == false]
      end
    end
    @results = rooms.map do |room|
      {:room => room, :messages => Message.select { |record|
        [record.room == room, record["body"] =~ @query]
      }}
    end
  end

  def _search_form
    Room.all_live.map do |room|
       [room.title, room.id]
    end
  end

end
