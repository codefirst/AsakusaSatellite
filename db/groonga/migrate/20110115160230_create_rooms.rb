class CreateRooms < ActiveGroonga::Migration
  def up
    create_table(:rooms) do |table|
      table.short_text(:name)
      table.timestamps
    end
  end

  def down
    remove_table(:rooms)
  end
end
