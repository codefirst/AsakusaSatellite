require 'asakusa_satellite/hook'

class AsakusaSatellite::Hook::RedmineTicketLinkHook < AsakusaSatellite::Hook::Listener
  UNSAFE_CHARACTERS = /[^-_.!~*'()a-zA-Z\d\/?:@=+$,\[\]]/
  def message_buttons(context)
    subject     = URI::escape(context[:message].body, UNSAFE_CHARACTERS)
    description = URI::escape(<<END, UNSAFE_CHARACTERS)
#{context[:message].user.name}: #{context[:message].body}

#{context[:permlink]}
END

    path = nil
    context[:self].instance_eval { path = image_path("redmine.png") }
    info = context[:message].room.yaml[:redmine_ticket]
    root         = info["root"]
    root << '/' unless root.end_with?('/')
    project_name = info["project_name"]
    url =  URI.join(root,
                    "./projects/#{project_name}/issues/new?issue[description]=#{description}&amp;issue[subject]=#{subject}")
    %(<a target="_blank" href="#{url}"><img src="#{path}" title="Redmine" class="icon" /></a>)
  rescue => e
    ""
  end
end
