class AsRedmineTicketLinkController < ApplicationController
  include RoomHelper
  def room
    find_room(params[:id]) do
      @hash   = @room.yaml[:redmine_ticket] || {}
      if request.post? then
        @hash.merge!(params[:config])
        @room.yaml = @room.yaml.merge :redmine_ticket => @hash
        @room.save!
        flash[:notice] = t(:notice_saved)
      end
      @config = OpenStruct.new(@hash)
    end
  end

  def global
  end
end
