require 'asakusa_satellite/hook'

class AsakusaSatellite::Hook::RedmineTicketLink < AsakusaSatellite::Hook::Listener
  def message_buttons(context)
    subject     = CGI.escape(context[:message].body)
    description = CGI.escape(<<"END")
#{context[:message].user.name}: #{context[:message].body}

#{context[:permlink]}
END

    path = nil
    context[:self].instance_eval { path = image_path("redmine.png") }

    project_name = context[:message].room.yaml[:redmine_ticket]["project_name"] rescue "undefined"
    url =  URI.join(config.roots,
                    "./projects/#{project_name}/issues/new?issue[description]=#{description}&issue[subject]=#{subject}")
    %(<a target="_blank" href="#{url}"><img src="#{path}" /></a>)
  end
end
