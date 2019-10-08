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
    user_info = AsakusaSatellite::OmniAuth::Adapter.adapt(request.env['omniauth.auth'])

    user = User.find_or_create_by({:screen_name => user_info[:screen_name]}).tap do |user|
      user.name              = user_info[:name]
      user.email             = user_info[:email]
      user.profile_image_url = user_info[:profile_image_url]
      user.register_spell if user.spell.blank?
      user.save
      set_current_user(user)
    end

    origin = request.env['omniauth.origin']
    params = request.env['omniauth.params'] || {}
    callback_scheme = params['callback_scheme']

    if callback_scheme
      redirect_to "#{CGI.escape callback_scheme}:///login?#{{:api_key => user.spell}.to_query}"
    elsif origin
      redirect_to origin
    else
      redirect_to :controller => :chat, :action => :index
    end
  end

  def logout
    if request.post?
      session.delete :cached_current_user
      session.delete :current_user_id
    end
    redirect_to(request.referer || root_path)
  end

  def failure
    redirect_back(:fallback_location => root_path, :alert => params[:message])
  end
end
