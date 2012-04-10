class ShardAddSchedulingIndexToEmails < ActiveRecord::Migration
  def change
    add_index :facebase_emails, [:schedule_at, :sent, :failed, :campaign, :stream, :component], :name => :scheduling_index
  end
end
