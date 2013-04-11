module AsakusaSatellite
  module OmniAuth
    class Adapter
      def self.adapt(omniauth_hash)
        {
          :name => omniauth_hash.info.name,
          :screen_name => omniauth_hash.info.nickname,
          :profile_image_url => omniauth_hash.info.image
        }
      end
    end
  end
end
