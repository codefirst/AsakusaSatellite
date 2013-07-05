require 'google/api_client'
require 'net/http'
require 'json'
require 'faraday'

class Chrome
  @@proxy = URI.parse(ENV["https_proxy"] || ENV["HTTPS_PROXY"] || "")
  @@proxy_connection = Faraday::Connection.new(:proxy => @@proxy.to_s)
  @@client = Google::APIClient.new
  @@client.authorization.client_id = ENV["GCM_CLIENT_ID"]
  @@client.authorization.client_secret = ENV["GCM_CLIENT_SECRET"]
  @@client.authorization.scope = "https://www.googleapis.com/auth/gcm_for_chrome"

  def self.auth_url(callback_url)
    @@client.authorization.redirect_uri = callback_url
    @@client.authorization.authorization_uri.to_s
  end

  def self.refresh_token(code)
    @@client.authorization.code = code
    @@client.authorization.fetch_access_token!(:connection => @@proxy_connection)
    ENV['GCM_REFRESH_TOKEN'] = @@client.authorization.refresh_token
    ENV['GCM_ACCESS_TOKEN']  = @@client.authorization.access_token
  end

  def self.send(channel_id, message_id)
    https = Net::HTTP::Proxy(@@proxy.host, @@proxy.port).new("www.googleapis.com", 443)
    https.use_ssl = true

    request = Net::HTTP::Post.new("/gcm_for_chrome/v1/messages")
    request.content_type = 'application/json'
    request["Authorization"] = "OAuth #{ENV['GCM_ACCESS_TOKEN']}"

    request.body = {
      :channelId => channel_id,
      :subchannelId => '0',
      :payload => message_id
    }.to_json

    case https.request(request)
    when Net::HTTPUnauthorized
      refetch_access_token
      request["Authorization"] = "OAuth #{ENV['GCM_ACCESS_TOKEN']}"
      https.request(request)
    end
  end

  private
  def self.refetch_access_token
    @@client.authorization.refresh_token = ENV["GCM_REFRESH_TOKEN"]
    @@client.authorization.fetch_access_token!(:connection => @@proxy_connection)
    ENV["GCM_ACCESS_TOKEN"] = @@client.authorization.access_token
  end
end
