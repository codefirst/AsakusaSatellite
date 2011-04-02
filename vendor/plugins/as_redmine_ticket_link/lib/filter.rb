require 'json'
require 'open-uri'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
class AsakusaSatellite::Filter::RedmineTicketLink < AsakusaSatellite::Filter::Base
  def process(text)
    text.gsub(/#(\d+)/) do|id|
      ticket $1, id
    end
  end

  private
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
        p e
        %[<a target="_blank" href="#{url}">#{ref}</a>]
      end
    else
      %[<a target="_blank" href="#{url}">#{ref}</a>]
    end
  end
end
