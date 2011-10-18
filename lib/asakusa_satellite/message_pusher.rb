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
        ::Pusher.app_id = opt['app_id']
        ::Pusher.key    = opt['key']
        ::Pusher.secret = opt['secret']
      end

      def trigger(channel, event, data)
        ::Pusher[channel].trigger(event, data)
      end

      def jsFile
        "http://js.pusherapp.com/1.9/pusher.min.js"
      end

      def jsClass
        "new Pusher('f36e789c57a0fc0ef70b')"
      end
    end

    class << self
      require 'forwardable'
      extend  Forwardable

      def_delegators :@default, :trigger, :jsFile, :jsClass

      def engines=(params)
        @params = params
      end

      def default=(name)
        @default = Engine[name].new(@params[name])
      end
    end
  end
end

