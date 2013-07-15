if defined?(Airbrake)
  Airbrake.configure do |config|
    config.api_key = ENV['AIRBRAKE_API_KEY']
    config.host    = ENV['AIRBRAKE_HOST'] || 'api.airbrake.io'
    config.port    = (ENV['AIRBRAKE_PORT'] || '80').to_i
    config.secure  = config.port == 443
  end

  if ENV['AIRBRAKE_API_KEY'].blank?
    module Airbrake
      class Sender
        def send_to_airbrake(notice)
          # do nothing
        end
      end
    end
  end
end
