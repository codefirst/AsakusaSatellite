class Room < ActiveGroonga::Base
  # get all rooms without deleted
  def self.all_live
    Room.select do |record|
      record.deleted == false
    end || []
  end
end
