require 'asakusa_satellite/hook'

class AsakusaSatellite::Hook::RedmineTicketLink < AsakusaSatellite::Hook::Listener
  def message_buttons(context)
    subject     = URI.escape(context[:message].body)
    description = URI.escape(<<"END")
#{context[:message].user.name}: #{context[:message].body}

#{context[:permlink]}
END

    path = nil
    context[:self].instance_eval { path = image_path("redmine.png") }
    info = context[:message].room.yaml[:redmine_ticket]
    root         = info["root"]
    project_name = info["project_name"]
    url =  URI.join(root,
                    "./projects/#{project_name}/issues/new?issue[description]=#{description}&issue[subject]=#{subject}")
    %(<a target="_blank" href="#{url}"><img src="#{path}" /></a>)
  rescue => e
    ""
  end
end
