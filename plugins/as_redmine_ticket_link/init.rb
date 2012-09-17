require 'asakusa_satellite/config'

require 'filter'
require 'view_hook'
AsakusaSatellite::Config.room("Redmine Ticket Link",
                              :controller=>:as_redmine_ticket_link, :action=> :room)
