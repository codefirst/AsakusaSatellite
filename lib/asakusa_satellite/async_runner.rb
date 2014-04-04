require 'eventmachine'

module AsakusaSatellite
  class AsyncRunner
    def self.run(&block)
      if EM.reactor_running?
        EM.defer(block)
      else
        block.call
      end
    end
  end
end

