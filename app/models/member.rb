class Member
  include Mongoid::Document
  include Mongoid::Timestamps
  embeds_one :room
  embeds_one :user
end
