# -*- encoding: utf-8 -*-
class ProfileSettingController < ApplicationController
  def update
    unless logged?
      redirect_to :controller => 'chat', :action => 'index'
      return
    end
    update_profile(params["account"], params["room"]["id"])
    redirect_to :controller => 'account'
  end

  private
  def update_profile(profile_info, room_id)
    user = User.first(:conditions => {:_id => current_user.id})
    user.user_profiles ||= []

    room = Room.where(:_id => room_id)[0]
    return if room.nil?

    if user.user_profiles.where(:room_id => room._id).empty?
      user.user_profiles << UserProfile.new(:room_id => room._id,
                                            :name => profile_info["name"],
                                            :profile_image_url => profile_info["image_url"])
    else
      profile = user.user_profiles.where(:room_id => room._id).first
      profile.update_attributes(:profile_image_url => profile_info["image_url"])
      profile.update_attributes(:name => profile_info["name"])
    end

    user.save
  end
end
