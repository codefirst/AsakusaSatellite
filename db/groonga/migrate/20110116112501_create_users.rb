class CreateUsers < ActiveGroonga::Migration
  def up
    create_table(:users) do |table|
      table.short_text(:name)
      table.short_text(:email)
    end
  end

  def down
    remove_table(:users)
  end
end
