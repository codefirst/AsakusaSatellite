class CreateTweets < ActiveGroonga::Migration
  def up
    create_table(:tweets) do |table|
      table.short_text(:content)
      table.reference(:room, "rooms")
      table.timestamps
    end
  end

  def down
    remove_table(:tweets)
  end
end
