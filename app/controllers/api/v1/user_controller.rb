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
        manage_device do |user|
          if user.devices.where(:name => params[:device]).empty?
            user.devices << Device.new(:name => params[:device],
                                       :device_name => params[:name],
                                       :device_type => params[:type] || 'iphone')
          end

          unless user.save
            render :json => {:status => 'error', :error => 'cannot save device data'}
          end
        end
      end

      def delete_device
        manage_device do |user|
          unless user.devices.where(:name => params[:device]).empty?
            device = user.devices.where(:name => params[:device])
            device.destroy
          end
        end
      end

      private
      def manage_device(&proc)
        user = User.where(:spell => params[:api_key]).first
        unless user
          render :json => {:status => 'error', :error => 'user not found'}
        end

        user.devices ||= []
        proc.call user
        render :json => user.to_json
      end

    end
  end
end
