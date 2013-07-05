# -*- coding: utf-8 -*-
AsakusaSatellite::Application.routes.draw do
  get 'chrome_notification/auth',     :controller => 'chrome', :action => 'auth'
  get 'chrome_notification/callback', :controller => 'chrome', :action => 'callback'
  get 'chrome_notification/register', :controller => 'chrome', :action => 'register'
end
