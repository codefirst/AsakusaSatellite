class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :device_name
  field :device_type
  embedded_in :User, :inverse_of => :devices

  @@after_save_procs = []
  def self.add_after_save(proc)
    @@after_save_procs << proc
  end
  after_save do |device|
    @@after_save_procs.each do |proc|
      proc.call(device)
    end
  end

  @@after_destory_procs = []
  def self.add_after_destroy(proc)
    @@after_destory_procs << proc
  end
  after_destroy do |device|
    @@after_destory_procs.each do |proc|
      proc.call(device)
    end
  end
end
