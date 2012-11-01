# -*- encoding: utf-8 -*-
class LoginController < ApplicationController
  protect_from_forgery :only => ["logout"]

  def index
  end

  def omniauth_callback
    adapter = AsakusaSatellite::Omniauth::Adapter.adapter(Setting['omniauth']['provider'])
    authenticated_user = adapter.adapt(request.env['omniauth.auth'])

    user = User.first(:conditions => {:screen_name => authenticated_user.screen_name})
    user ||= authenticated_user
    user.save
    set_current_user(user)
    redirect_to :controller => 'chat', :action => 'index'
  end

  def logout
    if request.post?
      session.delete :cached_current_user
      session.delete :current_user_id
    end
    redirect_to request.referer
  end
end
