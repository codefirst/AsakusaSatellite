# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
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
    @filter.process_all(plain).join.should have_xml("//div[@class='CodeRay']")
  end

  it '\n が LF に置換されない' do
    plain = [ "ruby::", "\"\\n\"",""]
    @filter.process_all(plain).join.should have_xml("//span[text()='\\n']")
  end

  it 'LF が \n に置換されない' do
    plain = [ "ruby::", "\"one\"\n\"two\"",""]
    @filter.process_all(plain).join.should have_xml("//pre[text()='\n']")
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
