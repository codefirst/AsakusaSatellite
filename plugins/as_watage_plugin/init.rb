require 'uri'
require 'json'
require 'rest-client'

module Watage
  class WatagePolicy
    def upload(filename, file, mimetype, message)
      uri = URI.parse Setting[:attachment_path]
      response_str = RestClient.post uri.to_s, { "upload[file]" => file }
      response = JSON.parse response_str
      response["source"]
    end
  end

  Attachment.register('watage', WatagePolicy)
end
