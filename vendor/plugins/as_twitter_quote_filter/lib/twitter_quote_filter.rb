require 'open-uri'
require 'nokogiri'

class TwitterQuoteFilter < AsakusaSatellite::Filter::Base

  def process(text, opts={})
    ast = Nokogiri::HTML::parse "<div>#{text}</div>"
    ast.xpath('//text()').each do |textnode|
      linkRegex = /https?:\/\/twitter\.com\/(?:#!\/)?([a-zA-Z0-9]+)\/status\/([0-9]+)/
      result = textnode.to_s.match linkRegex
      
      if result
        fragment = createTweetFragment(result[1], result[2])
        textnode.parent.replace fragment
      end
    end
    return ast.xpath('/html/body/div')[0].to_s
  end

  def createTweetFragment(userid, tweetid)
    tweet =
      Nokogiri::HTML(open "http://twitter.com/#{userid}/status/#{tweetid}").
      xpath('//div[@id="permalink"]')[0]

    fragment = Nokogiri::HTML::fragment <<-EOS
<div class='twq-body'>
  <div class='twq-left'>
    <div><img src='#{tweet.xpath('//div[@class="thumb"]//img/@src')}'/></div>
  </div>
  <div class='twq-right'>
    <div class='twq-right-top'>
      <a>#{tweet.xpath('//div[@class="full-name"]/text()')[0]}</a>
      #{tweet.xpath('//a[@class="tweet-url screen-name"]')[0]}
    </div>
    <div class='twq-right-bottom'>
      <div>#{tweet.xpath('//span[@class="entry-content"]')[0]}</div>
      <div>#{tweet.xpath('//span[@class="meta entry-meta"]')[0]}</div>
    </div>
  </div>
</div>
<style>
div.twq-body {
    background-color: white;
    -webkit-border-radius: 5px;
    border: 2px silver solid;
    padding: 10px 10px 10px 10px;
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
</style>
EOS

    puts fragment.to_s
    return fragment
  end

end

