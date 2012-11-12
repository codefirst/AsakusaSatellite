# -*- encoding: utf-8 -*-
class LoginController < ApplicationController
  protect_from_forgery :only => ["logout"]

  def index
  end

  # This is an old login URL. Please use omniauth login URL like /auth/:provider
  def oauth
    redirect_to "#{root_path}auth/#{Setting['omniauth']['provider']}"
  end

  def omniauth_callback
    authenticated_user = AsakusaSatellite::OmniAuth::Adapter.adapt(request.env['omniauth.auth'])
    user = User.first(:conditions => {:screen_name => authenticated_user.screen_name})
    user ||= authenticated_user
    user.save
    set_current_user(user)
    if request.env['omniauth.origin'].blank?
      redirect_to :controller => :chat, :action => :index
    else
      redirect_to request.env['omniauth.origin']
    end
  end

  def logout
    if request.post?
      session.delete :cached_current_user
      session.delete :current_user_id
    end
    redirect_to request.referer
  end

  def failure
    redirect_to :back, :alert => params[:message]
  end
end
