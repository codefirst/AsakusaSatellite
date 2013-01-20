class <%= class_name %>Listener < AsakusaSatellite::Hook::Listener
  # modify hook name
  render_on :hookname, :partial => "_view_file"

  # or define method by yourself
  def hookname(context)
    context[:controller].send(:render_to_string, {:locals => context, :partial => '_view_file'})
  end
end

