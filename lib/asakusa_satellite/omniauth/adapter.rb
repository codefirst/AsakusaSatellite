module AsakusaSatellite
  module Omniauth
    class Adapter
      @@adapters = {}
      def self.register(provider, klass)
        @@adapters[provider] = klass
      end
      def self.adapter(provider)
        @@adapters[provider]
      end
    end
  end
end
