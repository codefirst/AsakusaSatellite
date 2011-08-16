class AccountController < ApplicationController
  def index
    unless logged?
      redirect_to :controller => 'chat', :action => 'index'
      return
    end

    register_spell if current_user.spell.blank?

    if request.post?
      register_spell if params.has_key? "account"
      delete_device  if params.has_key? "device_deleted"
      redirect_to :controller => 'account'
    end

    @devices = current_user.devices
  end

  private
  def register_spell
    user = current_user
    user.spell = generate_spell
    user.save
  end

  def generate_spell
    length = (20..30).to_a.choice
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    Array.new(length) { chars[rand(chars.size)] }.join
  end

  def delete_device
    device_name = params["device_deleted"].keys[0]
    current_user.devices.where(:name => device_name).destroy
  end
end
