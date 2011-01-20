require 'oauth'
require 'json'
class LoginController < ApplicationController

  def index
  end

  def oauth
    callback_url = "http://#{request.host_with_port}/login/oauth_callback"
    request_token = self.class.consumer.get_request_token(:oauth_callback => callback_url)
    #request_token = self.class.consumer.get_request_token()

    session[:request_token] = {
      :token => request_token.token,
      :secret => request_token.secret
    }

    redirect_to request_token.authorize_url

    #    auth = LoginController.consumer
    #    request_token = OAuth::AccessToken.new(
    #      auth,
    #      'http://twitter.com/oauth/access_token',
    #      'http://twitter.com/oauth/authorize'
    #    )
    ##    request_token = auth.get_request_token(
    ##      :oauth_callback => "http://#{request.host_with_port}/oauth_callback"
    ##    )
    #    session[:request_token] = request_token.token
    #    session[:request_token_secret] = request_token.secret
    #    redirect_to request_token.authorize_url
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
        record['name'] =~ screen_name
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

    redirect_to :index
  end

  def logout
    session.delete :login_user_id
    User.current = nil
    redirect_to :controller => 'chat', :action => 'index'
  end
end
