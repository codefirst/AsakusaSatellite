require 'open-uri'
require 'nokogiri'

class TwitterQuoteFilter < AsakusaSatellite::Filter::Base

  def process_all(lines, opts={})
    text = lines.join '<br/>'
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
    url      = tweet.xpath('//a[@class="tweet-url screen-name"]/@href')[0]
    iconpath = tweet.xpath('//div[@class="thumb"]//img/@src')
    content  = tweet.xpath('//span[@class="entry-content"]')[0]
    updated  = tweet.xpath('//span[@class="meta entry-meta"]')[0]

    fragment = Nokogiri::HTML::fragment <<-EOS
<div class='twq-body'>
  <div class='twq-top'>
    <a href='#{url}'><img src='#{iconpath}'/></a>
    <span class='user-name'>#{CGI::unescapeHTML username.to_s}</span>
    <div class='update-time'>#{updated}</div>
  </div>
  <div class='twq-content clear'>#{CGI::unescapeHTML content.to_s}</div>
</div>
<style>
div.twq-body {
    background-color: white;
    -moz-border-radius: 5px 5px 5px 5px;
    -webkit-border-radius: 5px 5px 5px 5px;
    -moz-box-shadow: 1px 1px 2px #999;
    -webkit-box-shadow: 1px 1px 2px #999;
    border: 1px #EEE solid;
    padding: 10px 10px 10px 10px;
    margin: 5px 5px 5px 5px;
}
div.twq-body div {
    margin-top: 3px;
    margin-bottom: 3px;
}
div.twq-top a {
    float: left;
}
div.twq-top img {
    -moz-box-shadow: 1px 1px 2px #999;
    -webkit-box-shadow: 1px 1px 2px #999;
    -moz-border-radius: 2px 2px 2px 2px;
    -webkit-border-radius: 2px 2px 2px 2px;
    height: 2.5em;
    margin-right: 5px;
}
div.twq-top .user-name {
    font-weight: bold;
}
div.twq-top .update-time {
    margin-top: 0px;
}
div.twq-content {
    padding-left: 5px;
    padding-right: 5px;
}
</style>
EOS

    puts fragment.to_s
    return fragment
  end

end

