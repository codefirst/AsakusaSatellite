require 'gemoji'

class EmojiFilter < AsakusaSatellite::Filter::Base
  def process(text, opts={})
    text.gsub!(/:([^:\s]+):/) do
      icon = $1
      if Emoji.names.include?(icon)
        url = "/assets/emoji/#{icon}.png"
        %(<img src="#{url}" style="width:16px" title="#{icon}" alt="#{icon}"/>)
      else
        ":#{icon}:"
      end
    end
    text
  rescue
    text
  end
end
