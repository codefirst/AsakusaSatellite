# -*- mode:ruby; coding:utf-8 -*-

module ApiHelper
  def check_spell
    if params[:api_key]
      users = User.where(:spell => params[:api_key])
      if users.first
        session[:current_user_id] = users.first.id.to_s
      end
    end
    true
  end

  def render_login_error
    render :json => {:status => 'error', :error => 'login not yet'}
  end
end
