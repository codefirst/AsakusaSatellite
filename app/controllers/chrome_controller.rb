class ChromeController < ApplicationController
  include RoomHelper
  layout "application", :except => :background
  def background
  end
end
