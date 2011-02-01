class AsakusaSatellite::Filter::TwitterLink < AsakusaSatellite::Filter::Base
  def process(text)
    text.gsub(/@(.+)/) do|ref|
      %[<a href="http://twitter.com/#{$1}" target="_blank">#{ref}</a>]
    end
  end
end
