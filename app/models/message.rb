class Message < ActiveGroonga::Base
  def encode_json(_)
    { 'content' => self.content }.to_json
  end
end

