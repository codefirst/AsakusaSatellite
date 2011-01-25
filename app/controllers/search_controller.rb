class SearchController < ApplicationController
  def index
    @rooms = Room.all
  end

  def search
    if params[:search].blank? or params[:search][:message].blank?
      redirect_to :action => :index
    end
    @query = params[:search][:message]
    @results = Room.all.map do |room|
      {:room => room, :messages => Message.select { |record|
        record.room == room and record["body"] =~ @query
      }}
    end
  end

end
