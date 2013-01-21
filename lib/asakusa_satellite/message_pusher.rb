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
        [ "https://d3dy5gmtp8yhk7.cloudfront.net/1.9/pusher.min.js" ]
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
        body = params.map{|key,value| "#{escape(key.to_s)}=#{escape(value)}" }.join('&')
        begin
          Net::HTTP.start(uri.host, uri.port) do |http|
            http.post(uri.path, body)
          end
        rescue Errno::ECONNREFUSED => e
          Rails.logger.error e
        end
      end

      def escape(str)
        URI.escape(URI.escape(str), /[&+]/)
      end
    end

    class Socky < Engine
      require 'socky/client'
      def initialize(opt)
        @webSocket = opt['web_socket']
        @http      = opt['http']
        @app       = opt['app']
        @secret    = opt['secret']
        @client = ::Socky::Client.new(@http + '/' + @app, @secret)
      end

      def trigger(channel, event, data)
        @client.trigger!(event,
                         :channel => channel,
                         :data    => data)
      end

      def jsFiles
        ['http://js.socky.org/v0.5.0-beta1/socky.min.js']
      end

      def jsClass
        <<END
(function() {
 var map = {
  'connected' : 'socky:connection:established',
  'disconnected' : 'socky:connection:closed',
  'failed'    : 'socky:connection:error',
 }
 var obj = new Socky.Client('#{@webSocket + '/' + @app}');
 obj.connection = {
   bind : function(name, f) {
    obj.bind(map[name], f);
   }
 };
 return obj;
})()
END
      end
    end

    class << self
      require 'forwardable'
      extend  Forwardable

      def_delegators :@default, :trigger, :jsFiles, :jsClass
      attr_reader :name, :param

      def engines=(params)
        @params = params
      end

      def default=(name)
        @name = name
        @param = @params[name]
        @default = Engine[name].new(@params[name])
      end

      def trigger(*args)
        @default.trigger(*args) unless Rails.env == 'test'
      end
    end
  end
end
