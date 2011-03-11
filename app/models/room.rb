class Room < ActiveGroonga::Base

  # get all rooms without deleted
  def self.all_live
    Room.select do |record|
      record.deleted == false
    end || []
  end

  def to_json
    {
      :id => self.id,
      :name => self.title,
      :updated_at => self.updated_at,
      :user => (self.user ? self.user.to_json : nil)
    }
  end

  def validate(options = {})
    (not self.title.blank?) and super(options) 
  end
end
