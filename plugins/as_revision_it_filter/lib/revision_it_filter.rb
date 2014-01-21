class RevisionItFilter < AsakusaSatellite::Filter::Base

  def process(text, opts={})
    root = opts[:root] || ENV['REVISION_IT_URL'] || 'http://revision-it.herokuapp.com'
    text.gsub /rev:([0-9a-zA-Z]{6,})/ do|original|
      rev = $1
      begin
        open("#{root}/hash/#{rev}").read
      rescue
        original
      end
    end
  end
end

