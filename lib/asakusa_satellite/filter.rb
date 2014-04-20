# -*- coding: utf-8 -*-
require 'pathname'
require 'cgi'
require 'rexml/document'

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

    def initialize!(filter_config)
      @plugins = []
      @filter_config = filter_config
    end

    def children(doc, &f)
      doc.root.elements['/as'].to_a
    end
    private :children

    def escapeText(str)
      REXML::Text::normalize(str || '')
    end
    private :escapeText

    def process(message, room)
      all_process ||= @filter_config.filters.map{|c|
        @plugins.find{|p|
          p.class.name.underscore.split('/')[-1] == c['name']
        }
      }

      # process order
      # 1. process_all for all lines
      raw_lines = escapeText(message.body).split("\n")
      lines = all_process.reduce(raw_lines) do |lines, process|
        if process.respond_to? :process_all
          process.process_all(lines, :message => message, :room => room)
        else
          lines
        end
      end

      # 2. process for each text node
      body = lines.to_a.join("<br />")
      doc  = all_process.reduce(REXML::Document.new "<as>#{body}</as>") do |doc, process|
        if process.respond_to? :process
          doc.each_element('/as/text()').each do |node|
            s = process.process(node.to_s, :message => message, :room => room)
            children(REXML::Document.new("<as>#{s}</as>")).each do |x|
              node.parent.insert_before node, x
            end
            node.remove
          end
        end
        doc
      end

      # hack for some browser.
      # Convert <iframe /> to <iframe></iframe>
      %w(iframe script div).each do |name|
        doc.each_element("//#{name}") do |node|
          node << REXML::Text.new('')
        end
      end

      children(doc).join
    rescue => e
      Rails.logger.error e
      escapeText(message.body)
    end

    def add_filter(klass, config)
      @plugins << klass.new(config)
    end

    def [](name)
      @filter_config.filters.find { |c| c['name'] == name }
    end

    module_function :initialize!, :process, :add_filter, :[], :children, :escapeText
  end
end
