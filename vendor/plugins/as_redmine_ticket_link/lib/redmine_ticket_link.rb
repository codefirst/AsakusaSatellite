require 'uri'
class AsakusaSatellite::Filter::RedmineTicketLink < AsakusaSatellite::Filter::Base
  def process(text)
    text.gsub(/#(\d+)/) do|ref|
      %[<a target="_blank" href="#{config.roots}issues/#{$1}">#{ref}</a>]
    end
  end
end
