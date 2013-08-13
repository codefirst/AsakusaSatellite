# -*- encoding: utf-8 -*-
module Api
  module V1
    class LoginController < ApplicationController
      include ApiHelper
      respond_to :json
      def index
        ActiveSupport::Deprecation.warn "Api::V1::LoginController is deprecated. Instead, please use api_key parameter"
        users = User.where(:screen_name => params[:user], :spell => params[:password])
        if users.size == 0
          render_error 'login failed', 403
          return
        end
        session[:current_user_id] = users.first.id
        render :json => {:status => 'ok', :message => 'login successful'}
      end
    end
  end
end

