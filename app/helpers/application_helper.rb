require 'asakusa_satellite/hook'
module ApplicationHelper
  include AsakusaSatellite::Hook::Helper

  def logged?
    not current_user.nil?
  end

  def current_user
    user = User.find(session[:current_user_id])
  end

  def set_current_user(user)
    session[:current_user_id] = user.id
  end

  def image_mimetype?(mimetype)
    mimetype =~ /^image\//
  end
end
