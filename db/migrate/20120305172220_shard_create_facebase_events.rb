class ShardCreateFacebaseEvents < ActiveRecord::Migration
  def change
    create_table :facebase_events do |t|

      # Core event info
      t.integer :contact_id, :null => false
      t.integer :for_profile_id
      t.string :event_type, :null => false
      t.datetime :occurs_at, :null => false

      # Ranking level for this event
      t.integer :priority, :default => 50

      # Where this event originated from
      t.string :application_source, :null => false

      # Historical usage
      t.integer :times_executed, :default => 0, :null => false
      t.datetime :last_executed_at

      # Repetition
      t.boolean :repeats_yearly, :default => false, :null => false
      t.boolean :repeats_monthly, :default => false, :null => false
      t.boolean :repeats_weekly, :default => false, :null => false
      t.text :details

      t.timestamps
    end

    execute "ALTER TABLE facebase_events MODIFY for_profile_id BIGINT UNSIGNED NOT NULL"
  end
end
