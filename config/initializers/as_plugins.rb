# -*- encoding: utf-8 -*-

unless ENV["RAILS_ENV"] == 'test'
  AsakusaSatellite::Filter::Loader.load
else
  AsakusaSatellite::Filter::Loader.load_all
end
