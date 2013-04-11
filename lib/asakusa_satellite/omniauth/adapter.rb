module AsakusaSatellite
  module OmniAuth
    class Adapter
      def self.adapt(omniauth_hash)
        info = omniauth_hash.info

        User.find_or_create_by(:screen_name => info.nickname).tap do |user|
          user.name = info.name if info.name
          user.profile_image_url = info.image if info.image
          user.save
        end
      end
    end
  end
end
