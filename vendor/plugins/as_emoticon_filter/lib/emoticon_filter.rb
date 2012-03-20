class EmoticonFilter < AsakusaSatellite::Filter::Base
  require 'yaml'
  require 'pathname'
  @@resource_dir = 'emoticons'

  @@plugin_path = Pathname(__FILE__).dirname.dirname
  @@icon_path = Rails.root.join('public', @@resource_dir)

  @@translation_rule =
    YAML.load_file(@@plugin_path + "rule.yml").delete_if do |_,file|
      not (@@icon_path + file).exist?
    end

  def process(text, opts={})
    @@translation_rule.each_pair do |key,file|
      text.gsub!(key,
        "<img style='height:1.0em;' title='#{key}' src='/#{@@resource_dir}/#{file}'/>"
      )
    end
    return text
  end

end

