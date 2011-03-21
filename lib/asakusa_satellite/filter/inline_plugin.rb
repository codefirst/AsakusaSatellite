#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

class AsakusaSatellite::Filter::InlinePlugin < AsakusaSatellite::Filter::Base
  def self.plugin(name, &f)
    @@plugins ||= []
    @@plugins << name

    define_method "__process_for_#{name}", &f
  end

  def process(x)
    @@plugins.reduce(x) do|text, plugin|
      text.gsub(/::#{plugin}((?::[^ :]+)+)/) do
        args = $1.split(":")[1..-1]
        send "__process_for_#{plugin}", *args
      end
    end
  end
end
