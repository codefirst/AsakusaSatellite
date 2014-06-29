class UserProfile
  include Mongoid::Document
  include Mongoid::Timestamps
  field :room_id
  field :name
  field :profile_image_url
  embedded_in :User, :inverse_of => :user_profiles
end
