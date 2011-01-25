module ApplicationHelper
  def logged?
    not session[:current_user_id].nil?
  end

  def current_user
    User.find(session[:current_user_id])
  end

  def set_current_user(user)
    session[:current_user_id] = user.id
  end
end
