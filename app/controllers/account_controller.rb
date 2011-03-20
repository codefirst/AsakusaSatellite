class AccountController < ApplicationController
  def index
    unless logged?
      redirect_to :controller => 'chat', :action => 'index'
      return
    end

    if request.post? or current_user.spell.blank?
      user = current_user
      user.spell = generate_spell
      user.save
    end
  end

  private
  def generate_spell
    length = (20..30).to_a.choice
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    Array.new(length) { chars[rand(chars.size)] }.join
  end
end
