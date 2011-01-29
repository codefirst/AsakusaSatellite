require 'uri'
class AsakusaSatellite::Filter::RedmineTicketLink < AsakusaSatellite::Filter::Base
  def initialize(config)
    super
    @roots = URI.parse(config.roots)
  end

  def process(text)
    text.gsub(/#(\d+)/) do|ref|
      url = @roots + "#{@roots.path}/issues/#{$1}"
      %[<a href="#{url}">#{ref}</a>]
    end
  end
end
