require 'uri'
class AsakusaSatellite::Filter::AutoLink < AsakusaSatellite::Filter::Base
   @@picture = []
  def self.picture(regexp, &f)
    @@picture << [ regexp, f ]
  end

  def any(xs, &f)
    xs.each do|*x|
      ret = f[*x]
      return ret if ret
    end
    return nil
  end

  def process(text, opts={})
    text.gsub URI.regexp(%w[http https]) do|url|
      link,image = any(@@picture) do| regexp, handle |
        if (m = regexp.match(url)) then
          handle[*m.captures]
        end
      end

      if link && image then
        %[<a target="_blank" href="#{link}" class="expand-image"><img src="#{image}" /></a>]
      else
        %[<a target="_blank" href="#{url}">#{url}</a>]
      end
    end
  end

  picture /twitpic\.com\/([A-z0-9]+)/ do|r1|
    unless r1 == "photos" then
      ['http://twitpic.com/'+r1, 'http://twitpic.com/show/thumb/'+r1];
    end
  end

  picture /(f\.hatena\.ne\.jp\/(([^\/])[^\/]+)\/(([0-9]{8})[0-9]+))/i do|r1,r2,r3,r4,r5|
    ['http://'+r1, 'http://img.f.hatena.ne.jp/images/fotolife/'+r3+'/'+r2+'/'+r5+'/'+r4+'_120.jpg']
  end

  picture /movapic\.com\/pic\/([\d\w]+)/i do|r1|
    ['http://movapic.com/pic/'+r1, 'http://image.movapic.com/pic/s_'+r1+'.jpeg']
  end

  picture /yfrog.com\/([\d\w]+)/i do|r1|
    ['http://yfrog.com/'+r1, 'http://yfrog.com/'+r1+'.th.jpg']
  end

  picture /ow.ly\/i\/([\d\w]+)/i do|r1|
    ['http://ow.ly/i/'+r1, 'http://static.ow.ly/photos/thumb/'+r1+'.jpg']
  end

  picture /(youtu\.be\/|www\.youtube\.com\/watch\?v\=)([\d\-\w]+)/i do|r1,r2|
    ['http://youtu.be/'+r2, 'http://i.ytimg.com/vi/'+r2+"/hqdefault.jpg"]
  end

  picture /www\.nicovideo\.jp\/watch\/([a-z]*?)([\d]+)\??/i do|r1,r2|
    ['http://www.nicovideo.jp/watch/'+r1+r2, 'http://tn-skr.smilevideo.jp/smile?i='+r2]
  end

  picture /img.ly\/([\d\w]+)/i do|r1|
    ['http://img.ly/'+r1, 'http://img.ly/show/thumb/'+r1]
  end

  picture /plixi.com\/p\/([\d]+)/i do|r1|
    ['http://plixi.com/p/'+r1, 'http://api.plixi.com/api/tpapi.svc/json/imagefromurl?size=thumbnail&url=http://plixi.com/p/'+r1]
  end
end
