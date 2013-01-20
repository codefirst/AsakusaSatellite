module AsakusaSatellite
  module Filter
    class FilterConfig

      # filter.yml has an array
      class V1FilterConfig
        def initialize(array)
          @array = array || []
        end

        def filters
          @array
        end
        alias :plugins :filters

        def plugins_dirs
          Dir.glob((Rails.root + "plugins/*").to_s).map do |dir|
            File.basename(dir)
          end
        end
      end

      # filter.yml has a hash
      class V2FilterConfig
        def initialize(hash)
          @hash = hash || {}
        end

        def filters
          @hash["filters"] || []
        end

        def plugins
          filters_and_plugins.select do |plugin|
             plugin["name"]
          end
        end

        def plugins_dirs
          filters_and_plugins.map do |filter|
            dir = filter["dir"]
            dir ||= "as_" + filter["name"]
            dir
          end
        end

        private
        def filters_and_plugins
          (@hash["filters"] || []) + (@hash["plugins"] || [])
        end
      end


      def self.initialize!(config_content)
        @@config = FilterConfig.new(config_content)
      end

      def self.filters
        @@config.filters
      end

      def self.plugins
        @@config.plugins
      end

      def self.plugins_dirs
        @@config.plugins_dirs
      end


      def initialize(config_content)
        if config_content.class == Array
          @config = V1FilterConfig.new(config_content)
        else
          @config = V2FilterConfig.new(config_content)
        end
      end

      def filters
        @config.filters
      end

      def plugins
        @config.plugins
      end

      def plugins_dirs
        @config.plugins_dirs
      end

    end
  end
end
