class User < ActiveGroonga::Base
  def to_json
    {
      :id => self.id,
      :name => self.name,
      :email => self.email,
      :profile_image_url => self.profile_image_url,
    }
  end
end
