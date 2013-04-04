Rails.application.config.middleware.use OmniAuth::Builder do
  case Setting['omniauth']['provider_args']
  when NilClass
    provider Setting['omniauth']['provider'].to_sym
  when Hash
    args = Setting['omniauth']['provider_args'].inject({}){|h,(k,v)| h[k.to_sym] = v; h}
    provider Setting['omniauth']['provider'].to_sym, args
  when Array
    provider Setting['omniauth']['provider'].to_sym, *Setting['omniauth']['provider_args']
  end
end

