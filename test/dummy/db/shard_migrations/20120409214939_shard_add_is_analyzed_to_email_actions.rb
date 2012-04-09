class ShardAddIsAnalyzedToEmailActions < ActiveRecord::Migration
  def change
    add_column :facebase_email_actions, :is_analyzed, :boolean, :default => false, :null => false
    add_index :facebase_email_actions, :is_analyzed
  end
end
