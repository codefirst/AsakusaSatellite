require 'digest/sha1'
module OmniAuth
  module Strategies
    class Local
      include OmniAuth::Strategy
      def request_phase
        redirect "#{script_name}#{app.url_for(:controller => 'localauth', :action => 'login', :only_path => true)}"
      end

      def callback_phase
        username = request[:username]
        password = request[:password]
        return fail!('login failed') unless valid_local_user?(username, password)
        @info = {:name => username, :nickname => LocalUser[username]['screen_name'], :image => LocalUser[username]['profile_image_url']}
        super
      end

      info { @info }

      private
      def valid_local_user?(user_name, password)
        LocalUser[user_name] and LocalUser[user_name]['password'] == Digest::SHA1.hexdigest(password.strip)
      end
    end
  end
end
