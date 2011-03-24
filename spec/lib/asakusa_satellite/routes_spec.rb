# -*- mode:ruby; coding:utf-8 -*-
require 'asakusa_satellite/routes'

class MyRoutes < AsakusaSatellite::Routes
  source :src
  map :dest do
    src.map{|x| x + 1 }
  end

  map :dest_with_args do|n|
    src.map{|x| x + n }
  end
end

describe AsakusaSatellite::Routes do
  before do
    @routes = MyRoutes.new
  end

  describe "#map" do
    describe "引数なし" do
      before do
        @args = []
        @routes.dest.listen{|*args| @args = args }
        @routes.src.fire 0
      end

      subject{ @args }
      it { should == [1] }
    end

    describe "引数あり" do
      before do
        @args = []
        @routes.dest_with_args(2).listen{|*args| @args = args }
        @routes.src.fire 0
      end

      subject{ @args }
      it { should == [2] }
    end
  end
end
