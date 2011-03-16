class User < ActiveGroonga::Base
  def to_json
    {
      :id => self.id,
      :name => self.name,
      :screen_name => self.screen_name,
      :profile_image_url => self.profile_image_url,
    }
  end

  def rooms
    Member.select{|record|
      record.user == self.id
    }.map{|member|
      member.room
    }.to_a
  end
end
