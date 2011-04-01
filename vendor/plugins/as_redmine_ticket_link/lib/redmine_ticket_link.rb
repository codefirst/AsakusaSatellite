# -*- coding: undecided -*-
require 'uri'

require 'asakusa_satellite/config'

# add config panel
AsakusaSatellite::Config.room "Redmine Ticket Link", :controller=>:as_redmine_ticket_link, :action=> :room

