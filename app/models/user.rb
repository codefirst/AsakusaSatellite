class User < ActiveGroonga::Base
  def self.current=(user)
    @current_user = user
  end
  def self.current
    @current_user
  end
  def self.logged?
    not @current_user.nil?
  end
end
