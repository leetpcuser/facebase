class ShardAddIndexesToEvents < ActiveRecord::Migration
  def change
    # Foreign key speed
    add_index :facebase_events, :contact_id

    # Primary search queries for queueing
    add_index :facebase_events, [:occurs_at, :last_executed_at, :event_type, :application_source], :name => "upcoming_events_index"

  end
end
