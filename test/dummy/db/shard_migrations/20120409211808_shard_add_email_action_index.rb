class ShardAddEmailActionIndex < ActiveRecord::Migration
  def up
    add_index :facebase_email_actions, [:email_id, :action_type, :count], :name => :index_on_email_action_type_count
    add_index :facebase_email_actions, [:action_type, :count], :name => :index_on_action_type_count
  end

  def down
    remove_index :facebase_email_actions, [:email_id, :action_type, :count], :name => :index_on_email_action_type_count
    remove_index :facebase_email_actions, [:action_type, :count], :name => :index_on_action_type_count
  end
end
