# -*- mode:ruby; coding:utf-8 -*-
require 'asakusa_satellite/event'
module AsakusaSatellite
  class Routes
    def self.source(*names)
      names.each do|name|
        module_eval %{
          def #{name}
            @#{name} ||= AsakusaSatellite::Event.new
          end
        }
      end
    end

    def self.map(name,&f)
      define_method(name) {|*args|
        self.instance_exec(*args, &f)
      }
    end
  end
end

