require 'asakusa_satellite/config'

require 'redmine_ticket_link_filter'
require 'redmine_ticket_link_hook'
AsakusaSatellite::Config.room("Redmine Ticket Link",
                              :controller=>:as_redmine_ticket_link, :action=> :room)
