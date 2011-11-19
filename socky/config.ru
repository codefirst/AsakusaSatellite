require 'socky/server'

options = {
  :debug => true,
  :applications => {
    :as => 'secret',
  }
}

map '/websocket' do
  run Socky::Server::WebSocket.new options
end

map '/http' do
  use Rack::CommonLogger
  run Socky::Server::HTTP.new options
end
