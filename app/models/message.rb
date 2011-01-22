class Message < ActiveGroonga::Base
  def encode_json(_)
    { 
      'body' => self.body,
      'name' => self.user.name,
      'created_at' => self.created_at,
    }.to_json
  end
end

