require File.dirname(__FILE__) + '/../spec_helper'

describe :routes do
  describe '/ は' do
    it '部屋一覧ページを表示する' do
      pending 'ruby 1.8.7 でroute のテストの方法が分からないため'
      # 以下のテストが ruby 1.8.7 では通らない??
      { :get => '/' }.should route_to(:controller => 'chat', :action => 'index')
    end
  end
end
