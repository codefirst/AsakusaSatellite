module AsakusaSatellite
  module Omniauth
    class TwitterAdapter
      def initialize(omniauth_hash)
        @omniauth_hash = omniauth_hash
      end

      def name
        @omniauth_hash.info.name
      end

      def screen_name
        @omniauth_hash.info.nickname
      end

      def profile_image_url
        @omniauth_hash.info.image
      end
    end
  end
end
