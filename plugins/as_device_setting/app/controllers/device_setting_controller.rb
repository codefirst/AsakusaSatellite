# -*- encoding: utf-8 -*-
class DeviceSettingController < ApplicationController
  def update
    delete_device if logged?
    redirect_to :controller => 'account', :action => 'index'
  end

  private
  def delete_device
    device_name = params["device_deleted"].keys[0]
    current_user.devices.where(:name => device_name).destroy
  end
end
