class CreateMembers < ActiveGroonga::Migration
  def up
    create_table(:members) do |table|
      table.reference(:room, "rooms")
      table.reference(:user, "users")
      table.time(:created_at)
    end
  end

  def down
    remove_table(:members)
  end
end
