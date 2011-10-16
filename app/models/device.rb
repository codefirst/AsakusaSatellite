class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :device_name
  field :device_type
  embedded_in :User, :inverse_of => :devices
end
