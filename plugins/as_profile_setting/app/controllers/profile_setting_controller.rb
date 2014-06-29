# -*- encoding: utf-8 -*-
class ProfileSettingController < ApplicationController
  include ApiHelper
  before_filter :check_spell, :check_if_login

  def create
    current_user.find_or_create_profile_for(params[:new_room][:room_id]) if params[:new_room]
    redirect_to :controller => :account
  end

  def update
    if params[:remove]
      current_user.delete_profile_for(params[:room][:id])
    else
      current_user.update_profile_for(params[:room][:id], params[:account][:name], params[:account][:image_url])
    end

    redirect_to :controller => :account
  end

  private

  def check_if_login
    redirect_to :controller => :chat if current_user.nil?
  end
end
