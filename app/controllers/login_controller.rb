require 'oauth'
require 'json'
class LoginController < ApplicationController

  def index
  end

  def oauth
    callback_url = "http://#{request.host_with_port}/login/oauth_callback"
    request_token = self.class.consumer.get_request_token(:oauth_callback => callback_url)

    session[:request_token] = {
      :token => request_token.token,
      :secret => request_token.secret
    }

    session[:oauth_referer] = request.referer

    redirect_to request_token.authorize_url
  end

  def oauth_callback
    if params[:denied]
      session.delete :oauth
    else
      request_token = OAuth::RequestToken.new(
        self.class.consumer,
        session[:request_token][:token],
        session[:request_token][:secret]
      )

      access_token = request_token.get_access_token(
        {},
        :oauth_token => params[:oauth_token],
        :oauth_verifier => params[:oauth_verifier]
      )

      session[:oauth] = {
        :token => access_token.token,
        :secret => access_token.secret
      }
      
      screen_name = OAuthRubytter.new(access_token).user_timeline('').first.user.screen_name
      users = User.select('id, name') do |record|
        record['name'] == screen_name
      end
      if users.records.size > 0
        User.current = users.records.first
      else
        User.current = User.new(:name => screen_name)
        User.current.save
      end
      session[:login_user_id] = User.current.id
    end

    session.delete :request_token

    redirect_to session[:oauth_referer]
    session.delete :oauth_referer
  end

  def logout
    session.delete :login_user_id
    User.current = nil
    #redirect_to :controller => 'chat', :action => 'index'
    redirect_to request.referer
  end
end
