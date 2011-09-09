require 'asakusa_satellite/hook'
module ApplicationHelper
  include AsakusaSatellite::Hook::Helper

  def logged?
    not current_user.nil?
  end

  def current_user
    if session[:cached_current_user].nil?
      session[:cached_current_user] = User.where(:_id => session[:current_user_id]).first
    end
    session[:cached_current_user]
  end

  def set_current_user(user)
    session[:current_user_id] = user.id
  end

  def image_mimetype?(mimetype)
    mimetype =~ /^image\//
  end
end
