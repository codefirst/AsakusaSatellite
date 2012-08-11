# -*- encoding: utf-8 -*-
class ApplicationController < ActionController::Base
  #protect_from_forgery
  layout 'application'
  before_filter :check_login

  include ApplicationHelper
  include LoginHelper

  def self.consumer
    OAuth::Consumer.new(
      Setting[:oauth_request_token],
      Setting[:oauth_request_token_secret],
      { :site => Setting[:oauth_request_site] }
    )
  end

  def about
  end


  private
  def check_login
    logged?
  end
end
