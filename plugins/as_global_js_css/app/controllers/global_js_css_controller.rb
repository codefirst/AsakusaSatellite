# -*- encoding: utf-8 -*-
class GlobalJsCssController < ApplicationController
  def update
    url  = params["file"]["url"]
    type = params["file"]["type"]

    unless url.empty?
      GlobalJsCssFile.new({:url => url, :type => type}).save
    else
      if params["delete"]
        params["delete"].keys.each {|js| GlobalJsCssFile.where(:url => js).destroy}
      end
    end

    redirect_to :controller => 'application', :action => 'about'
  end
end
