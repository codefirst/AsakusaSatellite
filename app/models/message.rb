class Message < ActiveGroonga::Base
  def encode_json(_)
    {
      'id'   => self.id,
      'body' => self.body,
      'name' => (self.user ? self.user.name : 'Anonymous User'),
      'profile_image_url' => (self.user ? self.user.profile_image_url : ''),
      'created_at' => self.created_at,
    }.to_json
  end
end

