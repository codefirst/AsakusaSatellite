# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'code_highlight_filter'

describe CodeHighlightFilter do
  before do
    @filter = CodeHighlightFilter.new({})
  end

  it '変換しない' do
    expect(@filter.process_all(["test"])).to eq ["test"]
  end

  it 'ハイライトできる' do
    plain = [ "ruby::", "puts \"hello\"",""]
    expect(@filter.process_all(plain).join).to have_xml("//div[@class='CodeRay']")
  end

  it '\n が LF に置換されない' do
    plain = [ "ruby::", "\"\\n\"",""]
    expect(@filter.process_all(plain).join).to have_xml("//span[text()='\\n']")
  end

  it 'LF が \n に置換されない' do
    plain = [ "ruby::", "\"one\"\n\"two\"",""]
    expect(@filter.process_all(plain).join).to have_xml("//pre[text()='\n']")
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

    expect(@filter.process_all(plain.split("\n"))).to eq result
  end
end
