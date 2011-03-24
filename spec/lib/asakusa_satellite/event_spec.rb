#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'asakusa_satellite/event'

describe AsakusaSatellite::Event do
  share_examples_for "callback" do
    subject { @expect }
    it { should be_expected_messages_received }
  end

  before { @mock = mock }

  describe "基底" do
    before do
      @event = AsakusaSatellite::Event.new
      @id = @event.listen {|*args| @mock.call(*args) }
    end

    describe "fire" do
      describe "単一" do
        before do
          @expect = @mock.should_receive(:call).once
          @event.fire
        end
        it_should_behave_like 'callback'
      end

      describe "複数" do
        before do
          @expect = @mock.should_receive(:call).twice
          @event.fire; @event.fire
        end
        it_should_behave_like 'callback'
      end

      describe "引数付き" do
        before do
          @expect = @mock.should_receive(:call).with(1,2)
          @event.fire(1,2)
        end
        it_should_behave_like 'callback'
      end
    end

    describe "remove" do
      before do
        @event.remove @id
        @expect = @mock.should_not_receive(:call)
        @event.fire
      end

      it_should_behave_like 'callback'
    end
  end

  describe "合成" do
    before do
      @base = AsakusaSatellite::Event.new
    end

    describe "map" do
      before do
        @event = @base.map{|x| x + 1 }
        @event.listen {|*args| @mock.call(*args) }
        @expect = @mock.should_receive(:call).with(1)
        @base.fire 0
      end
      it_should_behave_like 'callback'
    end

    describe "filter" do
      before do
        @event = @base.filter{|x| x == 0 }
        @event.listen {|*args| @mock.call(*args) }
      end

      context "not filtered" do
        before do
          @expect = @mock.should_receive(:call).with(0)
          @base.fire 0
        end
        it_should_behave_like 'callback'
      end

      context "filtered" do
        before do
          @expect = @mock.should_not_receive(:call)
          @base.fire 1
        end
        it_should_behave_like 'callback'
      end
    end

    describe "merge" do
      before do
        @other = AsakusaSatellite::Event.new
        @event = @base.merge(:left,:right => @other)
        @event.listen {|*args| @mock.call(*args) }
      end

      context "left" do
        before do
          @expect = @mock.should_receive(:call).with(:left, 0)
          @base.fire 0
        end
        it_should_behave_like 'callback'
      end

      context "right" do
        before do
          @expect = @mock.should_receive(:call).with(:right, 1)
          @other.fire 1
        end
        it_should_behave_like 'callback'
      end

      context "複数引数" do
        before do
          @expect = @mock.should_receive(:call).with(:right, 1, 2)
          @other.fire 1,2
        end
        it_should_behave_like 'callback'
      end
    end
  end
end
