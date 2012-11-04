require 'rest_client'
require 'rexml/document'

class RedmineUser
  def initialize(key, redmine_url_base)
    begin
      @document = nil
      response = RestClient.get(
        redmine_url_base,
        {:params => {:key => key}}
        )
      @document = REXML::Document.new(response)
    rescue RestClient::Exception
    end
  end
  
  def name
    @document.root.elements['mail'].text
  end
  
  def screen_name
    first = @document.root.elements['firstname'].text
    last = @document.root.elements['lastname'].text
    "#{first} #{last}"
  end
  
  def exist?
    not @document.nil?
  end
end
