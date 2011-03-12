module Api
  module V1
    class UserController < ApplicationController
      def show
        users = User.select do |record|
          record['spell'] == params[:api_key]
        end
        if users and users.first
          render :json => users.first.to_json
          return
        end
        render :json => {:status => 'error', :error => 'user not found'}
      end
    end
  end
end
