# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../../spec/spec_helper'
require 'code_highlight_filter'

describe CodeHighlightFilter do
  before do
    @filter = CodeHighlightFilter.new({})
  end

  it '変換しない' do
    @filter.process("test").should == "test"
  end

  it '空のやつでもOK' do
    @filter.process("ruby::").should == ""
  end

  it 'ハイライトできる' do
    plain = <<END
ruby::
puts "hello"
END
    result = <<END
<div class="CodeRay">
  <div class="code"><pre>puts <span style="background-color:#fff0f0;color:#D20"><span style="color:#710">&quot;</span><span style="">hello</span><span style="color:#710">&quot;</span></span>
</pre></div>
</div>
END
    @filter.process(plain).should == result
  end
end
