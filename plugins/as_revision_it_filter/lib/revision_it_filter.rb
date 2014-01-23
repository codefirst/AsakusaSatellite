require 'open-uri'
require 'json'

class AsakusaSatellite::Filter::RevisionItFilter < AsakusaSatellite::Filter::Base

  def process(text, opts={})
    root = opts[:root] || ENV['REVISION_IT_URL'] || 'http://revision-it.herokuapp.com'
    text.gsub /rev:([0-9a-zA-Z]{6,})/ do|original|
      rev = $1
      begin
        hash = JSON.parse open("#{root}/hash/#{rev}.json").read
        if hash['status'] == 'ok' then
          hash_code = hash['revision']['hash_code']
          url = hash['revision']['url']
          log = hash['revision']['log']

          %(<a href="#{url}" target="_blank">#{hash_code[0,6]} #{log.split("\n").first}</a>)
        else
          original
        end
      rescue
        original
      end
    end
  end
end

