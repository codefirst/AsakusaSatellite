# -*- coding: utf-8 -*-
require 'json'
require 'open-uri'
require 'cgi'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
class AsakusaSatellite::Filter::RedmineTicketLinkFilter < AsakusaSatellite::Filter::Base
  def process(line, opts={})
    room = opts[:room]
    info = room.yaml[:redmine_ticket]
    return line if info.blank?
    line.gsub(/#(\d+)/) {|id|
      ticket $1, id, info
    }
  rescue => e
    line
  end

  private
  def ticket(id, ref, info)
    root_url = info['root']
    root_url << '/' unless root_url.end_with?('/')
    url =  URI.join(root_url,"./issues/#{id}")
    if info.key? 'api_key' then
      api =  URI.join(root_url,"./issues/#{id}.json?key=#{info['api_key']}")
      begin
        open(api.to_s) do|io|
          hash = JSON.parse(io.read)
          subject = REXML::Text::normalize hash["issue"]["subject"]
          if subject.respond_to? :force_encoding
            subject.force_encoding 'utf-8'
          end
          return %[<a target="_blank" href="#{url}">#{ref} #{subject}</a>]
        end
      rescue => e
        %[<a target="_blank" href="#{url}">#{ref}</a>]
      end
    else
      %[<a target="_blank" href="#{url}">#{ref}</a>]
    end
  end
end
