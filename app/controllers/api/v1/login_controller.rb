module Api
  module V1
    class LoginController < ApplicationController
      respond_to :json
      def index
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
        current_user = users.records.first
        render :json => {:status => 'ok', :message => 'login successful'}
      end
    end
  end
end

