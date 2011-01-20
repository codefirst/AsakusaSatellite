module ApplicationHelper
  def logged?
    User.logged?
  end
end
