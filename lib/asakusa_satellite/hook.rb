module AsakusaSatellite::Hook
  @@listeners = []

  class << self
    def add_listener(klass)
      @@listeners << klass.new
    end

    def call_hook(hook, context = {})
      @@listeners.map do |listener|
        next unless listener.respond_to?(hook)
        listener.send(hook, context)
      end.join {|elem| elem.class == String ? elem : ''}
    end
  end

  class Listener
    def self.inherited(klass)
      AsakusaSatellite::Hook.add_listener(klass)
      super
    end
  end


  module Helper
    def call_hook(hook, context = {})
      AsakusaSatellite::Hook.call_hook(hook, context)
    end
  end
end

