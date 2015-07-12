# -*- coding: utf-8 -*-
class CodeHighlightFilter < AsakusaSatellite::Filter::Base

  def process_all(lines, opts={})
    lang,*body = lines
    content = REXML::Text::unnormalize(body.join("\n"))
    case lang.strip
    when "graphviz::","graph::"
      %(<img class="graphviz" src="https://chart.googleapis.com/chart?cht=gv&amp;chl=#{CGI.escape content}" />)
    when /\A(\w+)::\Z/
      lexer_class = Rouge::Lexer.find($1)
      lexer = lexer_class ? lexer_class.new : Rouge::Lexers::PlainText.new
      formatter = Rouge::Formatters::HTML.new(:css_class => 'highlight', :inline_theme => 'github')
      [formatter.format(lexer.lex(content))]
    else
      lines
    end
  end
end

