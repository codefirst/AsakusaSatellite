class DesktopnotificationListener < AsakusaSatellite::Hook::Listener
  render_on  :account_setting_item, :partial => "desktopnotification_setting"

  def global_footer(context)
    controller = context[:request][:controller]
    action     = context[:request][:action]

    case {:controller => controller, :action => action}
    when {:controller => "account", :action => "index"}
      desktopnotification_script_tag(context, :desktopnotification) +
      desktopnotification_script_tag(context, :desktopnotification_setting)
    when {:controller => "chat",    :action => "room"}
      desktopnotification_script_tag(context, :desktopnotification) +
      desktopnotification_script_tag(context, :desktopnotification_notify)
    end
  end

  private
  def desktopnotification_script_tag(context, file)
    params = {:plugin => :as_desktopnotification, :type => :javascript, :format => :js}
    %(<script src="#{call_plugin_asset_path(context, params.merge(:file => file))}"></script>)
  end

  def call_plugin_asset_path(context, options)
    context[:controller].instance_eval { plugin_asset_path(options) }
  end
end

