class AccountController < ApplicationController
  def index
    unless User.logged?
      redirect_to :controller => 'chat', :action => 'index'
      return
    end 

    if request.post? or not User.current.spell
      length = (20..30).to_a.choice
      chars = ('a'..'Z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
      password = Array.new(length) { chars[rand(chars.size)] }.join
      User.current.spell = password
      User.current.save
    end
  end

end
