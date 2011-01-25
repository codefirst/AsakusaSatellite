class AccountController < ApplicationController
  def index
    unless logged?
      redirect_to :controller => 'chat', :action => 'index'
      return
    end 

    if request.post? or not current_user.spell
      length = (20..30).to_a.choice
      chars = ('a'..'Z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
      password = Array.new(length) { chars[rand(chars.size)] }.join
      current_user.spell = password
      current_user.save
    end
  end

end
