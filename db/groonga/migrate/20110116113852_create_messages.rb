class CreateMessages < ActiveGroonga::Migration
  def up
    create_table(:messages) do |table|
      table.reference(:room, "rooms")
      table.reference(:user, "users")
      table.short_text(:body)
      table.short_text(:filename)
      table.short_text(:disk_filename)
      table.timestamps
    end
  end

  def down
    remove_table(:messages)
  end
end
