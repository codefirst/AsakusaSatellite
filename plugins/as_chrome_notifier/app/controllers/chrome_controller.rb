class ChromeController < ApplicationController
  include ApiHelper
  before_filter :check_spell

  def auth
    callback_url = request.url.split("/").slice(0...-1).join("/") + "/callback"
    redirect_to(Chrome.auth_url(callback_url))
  end

  def callback
    refresh_token = Chrome.refresh_token(params[:code])
  end

  def register
    render_login_error and return unless logged?

    redirect_to({:controller => "api/v1/user", :action => "add_device",
                 :api_key => params[:api_key],
                 :name => "Chrome",
                 :device => params[:channel_id],
                 :type => "chrome"})
  end
end
