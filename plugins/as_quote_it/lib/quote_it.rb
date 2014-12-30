# -*- encoding: utf-8 -*-
require 'open-uri'

class AsakusaSatellite::Filter::QuoteIt < AsakusaSatellite::Filter::Base
  REGEXP = /((https?):\/\/[^\s　]+)/

  def process(text, opts={})
    root = opts[:root] || ENV['QUOTEIT_URL'] || 'https://quoteit.herokuapp.com'
    text.gsub REGEXP do |url|
      begin
        open("#{root}/clip.html?u=#{to_param(url)}").read
      rescue
        %[<a target="_blank" href="#{url}">#{url}</a>]
      end
    end
  end

  private
  def to_param(url)
    CGI.escape(REXML::Text.unnormalize(url))
  end
end

