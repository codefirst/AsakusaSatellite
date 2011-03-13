module AsakusaSatellite
  class Config
    def self.room(message, params)
      @rooms ||= []
      @rooms << [message, params]
    end

    def self.rooms
      @rooms
    end
  end
end

