Rails.application.routes.draw do
  get 'redmineauth', :controller => :redmineauth, :action => :index
  get 'redmineauth/login', :controller => :redmineauth, :action => :login
end
