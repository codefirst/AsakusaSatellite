class EmoticonFilter < AsakusaSatellite::Filter::Base

  @@path = '/emoticons'
  @@emoticon_db = {
    '(puke)' => 'puke.png'
  }

  def process(text, opts={})
    @@emoticon_db.each_pair do |keyword,filename|
      text.gsub!(keyword, "<img style='height:1.5em;' src='#{@@path}/#{filename}'/>")
    end
    return text
  end

end

