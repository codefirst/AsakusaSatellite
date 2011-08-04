# -*- coding: undecided -*-
require 'json'
require 'open-uri'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
class AsakusaSatellite::Filter::RedmineTicketLink < AsakusaSatellite::Filter::Base
  def process(line, opts={})
    # FIX ME OR DIE
    room = Room.where(:_id => opts[:message].room_id).first

    info = room.yaml[:redmine_ticket]
    line.gsub(/#(\d+)/) {|id|
      ticket $1, id, info
    }
  rescue
    line
  end

  private
  def ticket(id, ref, info)
    url =  URI.join(info['root'],"./issues/#{id}")
    if info.key? 'api_key' then
      api =  URI.join(info['root'],"./issues/#{id}.json?key=#{info['api_key']}")
      p api
      begin
        open(api.to_s) do|io|
          hash = JSON.parse(io.read)
          subject = hash["issue"]["subject"]
          return %[<a target="_blank" href="#{url}">#{ref} #{subject}</a>]
        end
      rescue => e
        p e
        %[<a target="_blank" href="#{url}">#{ref}</a>]
      end
    else
      %[<a target="_blank" href="#{url}">#{ref}</a>]
    end
  end
end
