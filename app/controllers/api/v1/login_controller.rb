module Api
  module V1
    class LoginController < ApplicationController
      respond_to :json
      def index
        ActiveSupport::Deprecation.warn "Api::V1::LoginController is deprecated. Instead, please use api_key parameter"
        users = User.select do |record|
          [
            record['screen_name'] == params[:user],
            record['spell'] == params[:password]
          ]
        end
        if users.records.size == 0
          render :json => {:status => 'error', :error => 'login failed'}
          return
        end
        session[:current_user_id] = users.first.id
        render :json => {:status => 'ok', :message => 'login successful'}
      end
    end
  end
end

