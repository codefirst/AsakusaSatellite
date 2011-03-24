#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module AsakusaSatellite
  class Event
    def initialize
      @listener = []
    end

    def listen(&f)
      @listener << f
      f
    end

    def fire(*args)
      @listener.each {|f| f[*args] }
    end

    def remove(id)
      @listener.delete id
    end

    def map(&f)
      compose do|event|
        self.listen{|*args| event.fire(f[*args]) }
      end
    end

    def filter(&f)
      compose do|event|
        self.listen{|*args| event.fire(*args) if f[*args] }
      end
    end

    def merge(name, others)
      compose do|event|
        self.listen{|*args| event.fire(name, *args) }

        others.each do|n, other|
          other.listen{|*args| event.fire(n, *args) }
        end
      end
    end

    private
    def compose(&f)
      event = self.class.new
      f[event]
      event
    end
  end
end
