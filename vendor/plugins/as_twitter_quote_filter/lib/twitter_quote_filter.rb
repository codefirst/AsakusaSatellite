require 'open-uri'
require 'nokogiri'

class TwitterQuoteFilter < AsakusaSatellite::Filter::Base

  def process_all(lines, opts={})
    text = (lines.join '<br/>')
    puts text
    ast = Nokogiri::HTML::parse "<div>#{text}</div>"
    ast.xpath('//text()').each do |textnode|
      linkRegex = /https?:\/\/twitter\.com\/(?:#!\/)?([a-zA-Z0-9_]+)\/status(?:es)?\/([0-9]+)/
      result = textnode.to_s.match linkRegex
      
      if result
        fragment = createTweetFragment(result[1], result[2])
        textnode.parent.replace fragment
      end
    end
    return [ast.xpath('/html/body/div')[0].to_s]
  end

  def createTweetFragment(userid, tweetid)
    tweet =
      Nokogiri::HTML(open "http://twitter.com/#{userid}/status/#{tweetid}").
      xpath('//div[@id="permalink"]')[0]
    username = tweet.xpath('//div[@class="full-name"]/text()')[0] ||
               tweet.xpath('//a[@class="tweet-url screen-name"]/text()')[0]
    iconpath = tweet.xpath('//div[@class="thumb"]//img/@src')
    content  = tweet.xpath('//span[@class="entry-content"]')[0]
    updated  = tweet.xpath('//span[@class="meta entry-meta"]')[0]

    fragment = Nokogiri::HTML::fragment <<-EOS
<div class='twq-body'>
  <div class='twq-left'>
    <div><img src='#{iconpath}'/></div>
  </div>
  <div class='twq-right'>
    <div class='twq-right-top'>
      <span class='user-name'>#{CGI::unescapeHTML username.to_s}</span>
    </div>
    <div class='twq-right-bottom'>
      <div>#{CGI::unescapeHTML content.to_s}</div>
      <div class='update-time'>#{updated}</div>
    </div>
    <div class='clear' />
  </div>
</div>
<style>
div.twq-body {
    background-color: white;
    -webkit-border-radius: 5px;
    border: 2px silver solid;
    padding: 10px 10px 10px 10px;
    margin: 5px 5px 5px 5px;
}
div.twq-left div {
    width: 10%;
    float: left;
}
div.twq-left div img {
    width: 100%;
    -webkit-border-radius: 5px;
}
div.twq-right {
    margin-left: 12%;
    width: 88%;
}
div.twq-right-top .user-name {
    font-weight: bold;
}
</style>
EOS

    puts fragment.to_s
    return fragment
  end

end

