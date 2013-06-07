class ChromeController < ApplicationController
  include ApiHelper
  before_filter :check_spell

  def auth
    callback_url = request.url.split("/").slice(0...-1).join("/") + "/callback"
    redirect_to(Chrome.auth_url(callback_url))
  end

  def callback
    refresh_token = Chrome.refresh_token(params[:code])
    render :json => {:status => 'ok', :refresh_token => refresh_token}
  end

  def register
    render_login_error and return unless logged?

    chrome = Chrome.register(params[:channel_id])
    render :json => {:status => 'ok', :chrome => chrome}
  end
end
