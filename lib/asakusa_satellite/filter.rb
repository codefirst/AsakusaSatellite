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

      def process(text, opts={})
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

    def process(message)
      @process ||= @config.map{|c|
        @plugins.find{|p|
          p.class.name.underscore.split('/')[-1] == c['name']
        }
      }

      text = message.body.to_s
      lines = CGI.escapeHTML(text).split("\n")
      @process.reduce(lines) do|lines, obj|
        if obj.respond_to? :process
          lines = lines.map{|line| obj.process(line, :message => message) }
        end

        if obj.respond_to? :process_all
          lines = obj.process_all lines, :message => message
        end

        lines
      end.join("<br />")
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
