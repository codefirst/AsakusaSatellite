require 'uri'
class AsakusaSatellite::Filter::AutoLink < AsakusaSatellite::Filter::Base
  def process(text)
    text.gsub(URI.regexp(%w[http https])){|url|
      %[<a href="#{url}">#{url}</a>]
    }
  end
end
