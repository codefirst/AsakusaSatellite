Rails.application.routes.draw do
  match ':controller(/:action(/:id(.:format)))' if Setting[:use_attachment_alias]
end
