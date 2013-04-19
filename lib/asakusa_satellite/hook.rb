module AsakusaSatellite::Hook
  @@listeners = []

  class << self
    def add_listener(klass)
      config = AsakusaSatellite::Hook[klass.name.underscore.split('/')[-1]]
      @@listeners << klass.new(OpenStruct.new(config))
    end

    def initialize!(filter_config)
      @filter_config = filter_config
    end

    def [](name)
      @filter_config.plugins.find { |c| c['name'] == name }
    end

    def call_hook(hook, context = {})
      @@listeners.inject '' do |html, listener|
        unless listener.respond_to?(hook)
          html
        else
          begin
            elem = listener.send(hook, context)
            html + ((elem.class == String and not elem.nil?) ? elem : '')
          rescue => e
            Rails.logger.error e
            html
          end
        end
      end
    end
  end

  class Listener
    include ERB::Util
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TextHelper
    include Rails.application.routes.url_helpers

    def self.inherited(klass)
      AsakusaSatellite::Hook.add_listener(klass)
      super
    end

    def self.render_on(hook, options={})
      define_method hook do |context|
        context[:controller].send(:render_to_string, {:locals => context}.merge(options))
      end
    end

    def initialize(config)
      @config = config
    end

    private
    def config
      @config
    end
  end


  module Helper
    def call_hook(hook, context = {})
      implicit_values = {}
      implicit_values[:controller] = controller if defined? controller
      implicit_values[:request] = request if defined? request
      AsakusaSatellite::Hook.call_hook(hook, context.merge(implicit_values))
    end
  end
end

