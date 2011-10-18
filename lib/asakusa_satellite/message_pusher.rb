# -*- mode:ruby; coding:utf-8 -*-

module AsakusaSatellite
  module MessagePusher
    class Engine
      @@engine = {}

      class << self
        def [](name)
          @@engine[name]
        end

        def inherited(klass)
          name = klass.name.gsub(/\A.*::/,'').downcase
          @@engine[name] = klass
        end
      end
    end

    class Pusher < Engine
      require 'pusher'
      def initialize(opt)
        @opt = opt
        ::Pusher.app_id = opt['app_id']
        ::Pusher.key    = opt['key']
        ::Pusher.secret = opt['secret']
      end

      def trigger(channel, event, data)
        ::Pusher[channel].trigger(event, data)
      end

      def jsFiles
        [ "http://js.pusherapp.com/1.9/pusher.min.js" ]
      end

      def jsClass
        key = @opt['key']
        "new Pusher('#{key}')"
      end
    end

    class Keima < Engine
      require 'net/http'
      require 'uri'
      def initialize(opt)
        @key = opt['key']
        @url = opt['url']
      end

      def trigger(channel, event, data)
        post("#{@url}/publish/#{@key}",{
               :channel => channel,
               :name    => event,
               :data    => data
             })
      end

      def jsFiles
        [ @url + '/socket.io/socket.io.js',
          @url + '/javascripts/keima.js' ]
      end

      def jsClass
        "new Keima('#{@key}')"
      end

      private
      def post(url,params)
        uri = URI.parse(url)
        body = params.map{|key,value| "#{URI.escape(key.to_s)}=#{URI.escape(value)}" }.join('&')
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.post(uri.path, body)
        end
      end
    end

    class << self
      require 'forwardable'
      extend  Forwardable

      def_delegators :@default, :trigger, :jsFiles, :jsClass

      def engines=(params)
        @params = params
      end

      def default=(name)
        @default = Engine[name].new(@params[name])
      end
    end
  end
end

