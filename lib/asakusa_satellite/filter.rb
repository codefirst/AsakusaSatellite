require 'pathname'
require 'cgi'

module AsakusaSatellite
  module Filter
    class Base
      attr_reader :config
      protected :config

      def initialize(config)
        @config = config
      end

      def process(text)
        text
      end

      def self.inherited(klass)
        filter_config = AsakusaSatellite::Filter[klass.name.underscore.split('/')[-1]]
        AsakusaSatellite::Filter.add_filter(klass, OpenStruct.new(filter_config)) if filter_config
      end
    end

    def initialize!(config)
      @plugins = []
      @config = config
    end

    def process(text)
      text = CGI.escapeHTML(text)

      @process ||= @config.map{|c|
        @plugins.find{|p|
          p.class.name.underscore.split('/')[-1] == c['name']
        }
      }

      @process.reduce(text) do|text, obj|
        obj.process text
      end
    end

    def add_filter(klass, config)
      @plugins << klass.new(config)
    end

    def [](name)
      @config.each do |c|
        return c if c['name'] == name
      end
      nil
    end

    module_function :initialize!, :process, :add_filter, :[]
  end
end
