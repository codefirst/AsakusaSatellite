# -*- coding: undecided -*-
class CodeHighlightFilter < AsakusaSatellite::Filter::Base

  def process_all(lines, opts={})
    lang,*body = lines
    content = CGI.unescapeHTML(body.join("\n"))
    case lang
    when "graphviz::","graph::"
      %(<img class="graphviz" src="http://chart.googleapis.com/chart?cht=gv&chl=#{CGI.escape content}" />)
    when /\A(\w+)::\Z/
      CodeRay.scan(content, $1).div.split '\n'
    else
      lines
    end
  end
end

