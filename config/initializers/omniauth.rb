Rails.application.config.middleware.use OmniAuth::Builder do
  provider Setting['omniauth']['provider'].to_sym, *Setting['omniauth']['provider_args']
end

