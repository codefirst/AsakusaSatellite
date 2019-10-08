Rails.application.routes.draw do
  get 'localauth', :controller => :localauth, :action => :index
  get 'localauth/login', :controller => :localauth, :action => :login
end
