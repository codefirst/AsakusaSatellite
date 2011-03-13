class AsRedmineTicketLinkController < ApplicationController
  include RoomHelper
  def room
    find_room(params[:id]){}
  end

  def global
  end
end
