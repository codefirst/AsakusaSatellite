class CreateAttachments < ActiveGroonga::Migration
  def up
    create_table(:attachments) do |table|
      table.short_text(:disk_filename)
      table.short_text(:filename)
      table.short_text(:content_type)
      table.reference(:message, "messages")
      table.timestamps
    end
  end

  def down
    remove_table(:attachments)
  end
end
