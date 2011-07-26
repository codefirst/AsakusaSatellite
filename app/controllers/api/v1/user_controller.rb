module Api
  module V1
    class UserController < ApplicationController
      def show
        users = User.where(:spell => params[:api_key])
        if users.first
          render :json => users.first.to_json
          return
        end
        render :json => {:status => 'error', :error => 'user not found'}
      end
    end
  end
end
