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

  def render_error(message)
    render :json => {:status => 'error', :error => message}
  end

  def render_login_error
    render_error "login not yet"
  end

  def render_error_on_save
    render_error "save failed"
  end

  def render_room_not_found(id)
    render_error "room #{id} not found"
  end

  def render_message_not_found(id)
    render_error "message #{id} not found"
  end

  def render_message_creation_error
    render_error "message creation failed"
  end

  def render_user_not_found(id)
    render_error "user #{id} not found"
  end
end
