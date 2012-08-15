require 'asakusa_satellite/hook'
module ApplicationHelper
  include AsakusaSatellite::Hook::Helper

  def logged?
    not current_user.nil?
  end

  def current_user
    @cached_user ||= User.where(:_id => session[:current_user_id]).first
  end

  def set_current_user(user)
    session[:current_user_id] = user.id
  end

  def image_mimetype?(mimetype)
    mimetype =~ /^image\//
  end

  def video_mimetype?(mimetype)
    mimetype =~ /^video\//
  end

end
