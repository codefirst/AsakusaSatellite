class UserProfile
  include Mongoid::Document
  include Mongoid::Timestamps
  field :room_id
  field :name
  field :profile_image_url
  embedded_in :User, :inverse_of => :user_profiles

  def to_json
    {
      :id => self.id.to_s,
      :room_id => self.room_id.to_s,
      :name => self.name,
      :profile_image_url => self.profile_image_url
    }
  end
end
