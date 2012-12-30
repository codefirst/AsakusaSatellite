class GlobalJsCssListener < AsakusaSatellite::Hook::Listener
  render_on :global_setting_item, :partial => "global_js_css_setting"

  def global_footer(context)
    GlobalJsCssFile.where(:type => "javascript").map do |js|
      "<script src='#{js.url}' type='text/javascript'></script>"
    end.join
  end

  def global_header(context)
    GlobalJsCssFile.where(:type => "css").map do |css|
      "<link href='#{css.url}' media='screen' rel='stylesheet' type='text/css'></link>"
    end.join
  end
end
