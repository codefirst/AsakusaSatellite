# -*- coding: utf-8 -*-
class WatageController < ApplicationController
  def show
    filename = "#{params[:id]}.#{params[:format]}"
    store_path = "#{Rails.root}/#{Setting[:attachment_path]}/#{filename}"

    File.open(store_path, "rb") do |f|
      send_data(f.read, :disposition=>'inline')
    end
  end
end
