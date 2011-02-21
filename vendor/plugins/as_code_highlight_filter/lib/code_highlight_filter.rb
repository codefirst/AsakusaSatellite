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

  def strip(xs)
    return [] if xs.empty?
    if xs.first.empty? then
      strip xs[1..-1]
    else
      xs
    end
  end

  def process_all(lines)
    xs = group(lines){|x| x =~ /\A\w+::/ }.map{|item|
      lang,*body = item
      content = CGI.unescapeHTML(body.join("\n"))
      case lang
      when "graphviz::","graph::"
        %(<img class="graphviz" src="http://chart.googleapis.com/chart?cht=gv&chl=#{CGI.escape content}" />)
      when /\A(\w+)::/
        CodeRay.scan(content, $1).div
      else
        item
      end
    }
    strip xs.flatten
  end
end

