module AsakusaSatellite::Hook
  @@listeners = []

  class << self
    def add_listener(klass)
      config = AsakusaSatellite::Hook[klass.name.underscore.split('/')[-1]]
      @@listeners << klass.new(OpenStruct.new(config))
    end

    def initialize!(config)
      @config = config
    end

    def [](name)
      @config.each do |c|
        return c if c['name'] == name
      end
      nil
    end

    def call_hook(hook, context = {})
      @@listeners.inject '' do |html, listener|
        unless listener.respond_to?(hook)
          html
        else
          elem = listener.send(hook, context)
          html + ((elem.class == String and not elem.nil?) ? elem : '')
        end
      end
    end
  end

  class Listener
    def self.inherited(klass)
      AsakusaSatellite::Hook.add_listener(klass)
      super
    end

    def initialize(config)
      @config = config
    end

    private
    def config
      @config
    end
  end


  module Helper
    def call_hook(hook, context = {})
      AsakusaSatellite::Hook.call_hook(hook, context)
    end
  end
end

