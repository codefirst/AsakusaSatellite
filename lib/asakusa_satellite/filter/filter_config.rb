module AsakusaSatellite
  module Filter
    class FilterConfig

      # filter.yml has an array
      class V1FilterConfig
        def initialize(array)
          @array = array
        end

        def filters
          @array
        end

        def plugins_dirs
          Dir.glob((Rails.root + "plugins/*").to_s).map do |dir|
            File.basename(dir)
          end
        end
      end

      # filter.yml has a hash
      class V2FilterConfig
        def initialize(hash)
          @hash = hash
        end

        def filters
          @hash["filters"] || []
        end

        def plugins_dirs
          ((@hash["filters"] || []) + (@hash["plugins"] || [])).map do |filter|
            dir = filter["dir"]
            dir = "as_" + filter["name"] unless dir
            dir
          end
        end
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

      def plugins_dirs
        @config.plugins_dirs
      end

    end
  end
end
