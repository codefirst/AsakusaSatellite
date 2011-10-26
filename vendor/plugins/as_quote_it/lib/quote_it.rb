require 'open-uri'
require 'nokogiri'
require 'cgi'

class AsakusaSatellite::Filter::QuoteIt < AsakusaSatellite::Filter::Base
 def process(text, opts={})
   root = opts[:root] || 'http://quoteit.heroku.com'
   text.gsub URI.regexp(%w[http https]) do|url|
      begin
        open("#{root}/clip.html?u=#{CGI.escape url}").read
      rescue
        "<a target='_blank' href='#{url}'>#{url}</a>"
      end
    end
 end
end

