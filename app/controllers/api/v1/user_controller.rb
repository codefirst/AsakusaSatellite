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

      def add_device
        user = User.where(:spell => params[:api_key]).first
        unless user
          render :json => {:status => 'error', :error => 'user not found'}
        end

        user.devices ||= []
        user.devices << Device.new(:name => params[:device])

        unless user.save
          render :json => {:status => 'error', :error => 'cannot save device data'}
        end
        render :json => user.to_json
      end
    end
  end
end
