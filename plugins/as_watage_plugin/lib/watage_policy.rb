require 'uri'
require 'json'
require 'rest-client'

module Watage
  class WatagePolicy
    def upload(filename, file, mimetype, message)
      uri = URI.parse("#{Setting[:attachment_path]}/api/v1/put")
      response_str = RestClient.post(uri.to_s, {
                       "upload[file]" => file,
                       "access_token" => Setting[:watage_token],
                       "access_token_secret" => Setting[:watage_token_secret]})
      response = JSON.parse response_str
      response["source"]
    end
  end

  Attachment.register('watage', WatagePolicy)
end

