class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  embedded_in :User, :inverse_of => :devices

end
