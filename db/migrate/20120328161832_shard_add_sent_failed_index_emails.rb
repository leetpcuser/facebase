class ShardAddSentFailedIndexEmails < ActiveRecord::Migration
  def up
    add_index :facebase_emails, [:sent, :failed]
  end

  def down
    remove_index :facebase_emails, [:sent, :failed]
  end
end
