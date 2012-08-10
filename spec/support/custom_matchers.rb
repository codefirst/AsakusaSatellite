RSpec::Matchers.define :have_json do |selector|
  match do |response_body|
    selector.gsub!(/_/,'-')
    json = JSON.parse(response_body)
    prefix = case json
    when Array
      "/objects/object"
    when Hash
      "/hash"
    end
    doc = REXML::Document.new(json.to_xml).root
    REXML::XPath.match(doc, prefix + selector).size > 0
  end
end


RSpec::Matchers.define :have_xml do |selector|
  match do |response_body|
    selector.gsub!(/_/,'-')
    doc = REXML::Document.new(response_body).root
    REXML::XPath.match(doc, selector).size > 0
  end
end
