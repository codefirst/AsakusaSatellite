class CreateRooms < ActiveGroonga::Migration
  def up
    create_table(:rooms) do |table|
      table.short_text(:title)
      table.reference(:user, "users")
      table.boolean(:deleted)
      table.timestamps
    end
  end

  def down
    remove_table(:rooms)
  end
end
