class AsakusaSatellite::Filter::TwitterLink < AsakusaSatellite::Filter::Base
  def process(text)
    text.gsub(/@([A-Za-z0-9_]+)/) do|ref|
      %[<a href="http://twitter.com/#{$1}" target="_blank">#{ref}</a>]
    end
  end
end
