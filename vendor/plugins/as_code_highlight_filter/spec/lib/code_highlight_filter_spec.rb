# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require 'code_highlight_filter'

describe CodeHighlightFilter do
  before do
    @filter = CodeHighlightFilter.new({})
  end

  it '変換しない' do
    @filter.process_all(["test"]).should == ["test"]
  end

  it 'ハイライトできる' do
    plain = [ "ruby::", "puts \"hello\"",""]

    result = <<END
<div class="CodeRay">
  <div class="code"><pre>puts <span style="background-color:#fff0f0;color:#D20"><span style="color:#710">&quot;</span><span style="">hello</span><span style="color:#710">&quot;</span></span>
</pre></div>
</div>
END
    @filter.process_all(plain).join.should have_xml("//div[@class='CodeRay']")
  end

  it "graphvizの可視化に対応" do
    graph = <<END
digraph sample {
 alpha -> beta;
 alpha -> gamma;
 beta -> delta;
}
END

    plain = <<"END"
graphviz::
#{graph}
END

    result = %(<img class="graphviz" src="http://chart.googleapis.com/chart?cht=gv&amp;chl=#{CGI.escape graph.strip}" />)

    @filter.process_all(plain.split("\n")).should == result
  end
end
