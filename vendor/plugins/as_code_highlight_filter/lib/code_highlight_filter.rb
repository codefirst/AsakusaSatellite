# -*- coding: undecided -*-
class CodeHighlightFilter < AsakusaSatellite::Filter::Base

  def group(xs,&p)
    yss = []
    ys = []
    xs.each do|x|
      if p[x] then
        yss << ys
        ys = [ x ]
      else
        ys << x
      end
    end
    yss << ys
  end

  def process(text)
    group(text){|x| x =~ /\A\w+::/ }.map{|item|
      lang,*body = item
      case lang
      when /\A(\w+)::/
        CodeRay.scan(body.join(""), $1).div
      else
        item.join("")
      end
    }.join("")
  end
end

