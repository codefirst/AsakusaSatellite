# -*- encoding: utf-8 -*-
class LoginController < ApplicationController
  protect_from_forgery :only => ["logout"]

  def index
  end

  def omniauth_callback
    adapter_class = AsakusaSatellite::Omniauth::Adapter.adapter(Setting['omniauth']['provider'])
    adapter = adapter_class.new(request.env['omniauth.auth'])

    user = User.first(:conditions => {:screen_name => adapter.screen_name})
    user ||= User.new
    user.screen_name = adapter.screen_name
    user.name = adapter.name
    user.profile_image_url = adapter.profile_image_url
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
