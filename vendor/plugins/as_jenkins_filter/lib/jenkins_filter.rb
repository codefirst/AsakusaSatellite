require 'asakusa_satellite/filter/inline_plugin'

class JenkinsFilter < AsakusaSatellite::Filter::InlinePlugin
  plugin :jenkins do|job, id|
    link = URI.join(config.roots,"./job/#{job}/#{id}")
    %(<a href="#{link}">::jenkins:#{job}:#{id}</a>)
  end
end

