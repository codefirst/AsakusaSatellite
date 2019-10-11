Rails.application.routes.draw do
  get 'as_redmine_ticket_link/room', :controller => 'as_redmine_ticket_link', :action => :room
  get 'as_redmine_ticket_link/global', :controller => 'as_redmine_ticket_link', :action => :global
end
