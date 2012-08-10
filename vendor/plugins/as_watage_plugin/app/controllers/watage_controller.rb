# -*- coding: utf-8 -*-
class WatageController < ApplicationController
  def show
    name = params[:id]
    format = params[:format]

    # todo: set correct mimetype
    File.open("#{Rails.root}/#{Setting[:attachment_path]}/#{name}.#{format}", "rb") do |file|
      send_data(file.read, :type => 'image/jpeg', :disposition=>'inline')
    end
  end
end
