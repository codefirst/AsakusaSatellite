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
        @@klass = klass
      end

      def self.sub_class
        @@klass
      end
    end

    def initialize!(config)
      base = Pathname.new(File.dirname(__FILE__)) + 'filter/'

      @plugins = []
      config.each do|c|
        c = OpenStruct.new c

        require base + c.name.underscore
        @plugins << Base.sub_class.new(c)
      end
    end

    def process(text)
      text = CGI.escapeHTML(text).gsub("\n", "<br />")
      @plugins.reduce(text) do|text, obj|
        obj.process text
      end
    end

    module_function :initialize!, :process
  end
end
