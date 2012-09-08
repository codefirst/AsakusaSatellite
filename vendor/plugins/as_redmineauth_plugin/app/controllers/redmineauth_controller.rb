class RedmineauthController < ApplicationController
  before_filter :configured?
  def index
    redirect_to :action => 'login'
  end

  def login
    if request.post?
      redmine_user = RedmineUser.new(params[:login][:key])
      unless redmine_user.exist?
        flash[:error] = 'login failed'
        return
      end
      
      user = User.first(:conditions => {:screen_name => redmine_user.name})
      user ||= User.new
      user.screen_name ||= redmine_user.name
      user.name ||= redmine_user.screen_name
      user.profile_image_url = 'data:image/gif;base64,R0lGODlhEAAQAMQfAFWApnCexR4xU1SApaJ3SlB5oSg9ZrOVcy1HcURok/Lo3iM2XO/i1lJ8o2eVu011ncmbdSc8Zc6lg4212DZTgC5Hcmh3f8OUaDhWg7F2RYlhMunXxqrQ8n6s1f///////yH5BAEAAB8ALAAAAAAQABAAAAVz4CeOXumNKOpprHampAZltAt/q0Tvdrpmm+Am01MRGJpgkvBSXRSHYPTSJFkuws0FU8UBOJiLeAtuer6dDmaN6Uw4iNeZk653HIFORD7gFOhpARwGHQJ8foAdgoSGJA1/HJGRC40qHg8JGBQVe10kJiUpIQA7'
      user.save
      session[:current_user_id] = user.id
      redirect_to :controller => 'chat', :action => 'index'
    end

  end

  private
  def configured?
    unless Setting[:login_link]
      logger.info "not configured!!"
      render :file => 'public/404.html'
    end
  end
end
