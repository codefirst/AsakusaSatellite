Rails.application.config.middleware.use OmniAuth::Builder do
  if Setting['omniauth']['provider_args'].nil? or Setting['omniauth']['provider_args'].empty?
    provider Setting['omniauth']['provider'].to_sym
  else
    provider Setting['omniauth']['provider'].to_sym, *Setting['omniauth']['provider_args']
  end
end

