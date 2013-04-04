Rails.application.config.middleware.use OmniAuth::Builder do
  if Setting['omniauth']['provider_args'].nil? or Setting['omniauth']['provider_args'].empty?
    provider Setting['omniauth']['provider'].to_sym
  else
    if Setting['omniauth']['provider_args'].class == Hash
      args = {}
      Setting['omniauth']['provider_args'].map {|k,v| args[k.to_sym] = v}
      provider Setting['omniauth']['provider'].to_sym, args
    else
      provider Setting['omniauth']['provider'].to_sym, *Setting['omniauth']['provider_args']
    end
  end
end

