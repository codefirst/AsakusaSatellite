class EmojiFilter < AsakusaSatellite::Filter::Base
  def process(text, opts={})
    root = URI(ENV["AS_EMOJI_URL_ROOT"]+"/")
    text.gsub!(/:([^:]+):/) do
      url = root + URI.escape("#{$1}.png",/[^-_.!~*'()a-zA-Z\d;\/?:@&=$,\[\]]/n)
      %(<img src="#{url}" width="16"/>)
    end
    text
  end
end
