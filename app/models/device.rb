class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :device_name
  field :device_type
  embedded_in :User, :inverse_of => :devices

  def ios?
    device_type.nil? or device_type == "iphone"
  end

  def self.register_callback(event)
    class_eval <<-EOS
      @@#{event.to_s}_procs = []
      def self.add_#{event.to_s}(&proc)
        @@#{event.to_s}_procs << proc if block_given?
      end
      #{event.to_s} do |device|
        @@#{event.to_s}_procs.each do |proc|
          proc.call(device)
        end
      end
    EOS
  end
  register_callback :after_save
  register_callback :after_destroy

end
