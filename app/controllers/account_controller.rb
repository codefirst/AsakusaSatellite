# -*- encoding: utf-8 -*-
class AccountController < ApplicationController
  def index
    unless logged?
      redirect_to :controller => 'chat', :action => 'index'
      return
    end

    current_user.register_spell if current_user.spell.blank?

    if request.post?
      current_user.register_spell if params.has_key? "account"
      redirect_to :controller => 'account'
    end

    @devices = current_user.devices
  end

end
