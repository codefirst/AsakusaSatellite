module OmniAuth
  module Strategies
    class Redmine
      include OmniAuth::Strategy

      DEFAULT_IMAGE_URL = 'data:image/gif;base64,R0lGODlhEAAQAMQfAFWApnCexR4xU1SApaJ3SlB5oSg9ZrOVcy1HcURok/Lo3iM2XO/i1lJ8o2eVu011ncmbdSc8Zc6lg4212DZTgC5Hcmh3f8OUaDhWg7F2RYlhMunXxqrQ8n6s1f///////yH5BAEAAB8ALAAAAAAQABAAAAVz4CeOXumNKOpprHampAZltAt/q0Tvdrpmm+Am01MRGJpgkvBSXRSHYPTSJFkuws0FU8UBOJiLeAtuer6dDmaN6Uw4iNeZk653HIFORD7gFOhpARwGHQJ8foAdgoSGJA1/HJGRC40qHg8JGBQVe10kJiUpIQA7'

      args [:login_link_redmine]

      def request_phase
        redirect "#{script_name}#{app.url_for(:controller => 'redmineauth', :action => 'login', :only_path => true)}"
      end

      def callback_phase
        redmine_user = RedmineUser.new(request[:login_key], "#{options.login_link_redmine}/users/current.xml")

        return fail!('login failed') unless redmine_user.exist?
        return fail!('login failed') if redmine_user.screen_name.blank?

        name = request[:login_name]
        name = redmine_user.name if name.blank?

        image_url = request[:image_url]
        image_url = DEFAULT_IMAGE_URL if image_url.blank?

        @info = {:name => redmine_user.screen_name, :nickname => name, :image => image_url}
        super
      end

      info { @info }
    end
  end
end
