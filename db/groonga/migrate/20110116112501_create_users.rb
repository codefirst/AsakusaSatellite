class CreateUsers < ActiveGroonga::Migration
  def up
    create_table(:users) do |table|
      table.short_text(:name)
      table.short_text(:screen_name)
      table.short_text(:email)
      table.short_text(:profile_image_url)
    end
  end

  def down
    remove_table(:users)
  end
end
