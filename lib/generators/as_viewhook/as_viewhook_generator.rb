class AsViewhookGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_as_viewhook_file
    template 'init.rb',
             "plugins/as_#{file_name.underscore}/init.rb"
    template 'as_viewhook.rb',
             "plugins/as_#{file_name.underscore}/lib/#{file_name.underscore}.rb"
    template 'spec.rb',
             "plugins/as_#{file_name.underscore}/spec/lib/#{file_name.underscore}_spec.rb"
  end
end
