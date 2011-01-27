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
    doc = Nokogiri::XML(json.to_xml)
    doc.search(prefix + selector).size > 0
  end
end
