module AllowDestructiveFieldInMongoid
  def destructive_fields
    []
  end
end

Mongoid.extend(AllowDestructiveFieldInMongoid)
