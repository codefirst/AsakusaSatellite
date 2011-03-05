# -*- coding: undecided -*-
require 'uri'
require 'asakusa_satellite/hook'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class AsakusaSatellite::Filter::RedmineTicketLink < AsakusaSatellite::Filter::Base
  def link_only(id, ref)
  end

  def ticket(id, ref)
    url =  URI.join(config.roots,"./issues/#{id}")
    if config.api_key then
      api =  URI.join(config.roots,"./issues/#{id}.json?key=#{config.api_key}")
      begin
        open(api.to_s) do|io|
          hash = JSON.parse(io.read)
          subject = hash["issue"]["subject"]
          return %[<a target="_blank" href="#{url}">#{ref} #{subject}</a>]
        end
      rescue => e
        %[<a target="_blank" href="#{url}">#{ref}</a>]
      end
    else
      %[<a target="_blank" href="#{url}">#{ref}</a>]
    end
  end

  def process(text)
    text.gsub(/#(\d+)/) do|id|
      ticket $1, id
    end
  end
end

class AsakusaSatellite::Hook::RedmineTicketLink < AsakusaSatellite::Hook::Listener
  def message_buttons(context)
    subject = CGI.escape(context[:message].body)

    description = CGI.escape(<<"END")
#{context[:message].user.name}: #{context[:message].body}

#{context[:permlink]}
END

    path = nil
    context[:self].instance_eval do
      path = image_path("redmine.png")
    end

    url =  URI.join(config.roots,"./projects/#{config.project}/issues/new?issue[description]=#{description}&issue[subject]=#{subject}")
    %(<a target="_blank" href="#{url}"><img src="#{path}" /></a>)
  end
end

