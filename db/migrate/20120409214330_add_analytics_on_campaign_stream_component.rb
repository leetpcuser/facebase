class AddAnalyticsOnCampaignStreamComponent < ActiveRecord::Migration
  def change

    # Campaign Analytics
    add_column :facebase_campaigns, :opens, :integer, :default => 0, :null => false
    add_column :facebase_campaigns, :clicks, :integer, :default => 0, :null => false
    add_column :facebase_campaigns, :unsubscribes, :integer, :default => 0, :null => false
    add_column :facebase_campaigns, :spams, :integer, :default => 0, :null => false
    add_column :facebase_campaigns, :delivered, :integer, :default => 0, :null => false

    # Stream Analytics
    add_column :facebase_streams, :opens, :integer, :default => 0, :null => false
    add_column :facebase_streams, :clicks, :integer, :default => 0, :null => false
    add_column :facebase_streams, :unsubscribes, :integer, :default => 0, :null => false
    add_column :facebase_streams, :spams, :integer, :default => 0, :null => false
    add_column :facebase_streams, :delivered, :integer, :default => 0, :null => false

    # Stream Analytics
    add_column :facebase_components, :opens, :integer, :default => 0, :null => false
    add_column :facebase_components, :clicks, :integer, :default => 0, :null => false
    add_column :facebase_components, :unsubscribes, :integer, :default => 0, :null => false
    add_column :facebase_components, :spams, :integer, :default => 0, :null => false
    add_column :facebase_components, :delivered, :integer, :default => 0, :null => false
  end
end
