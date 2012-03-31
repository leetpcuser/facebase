# This migration comes from facebase (originally 20120305195448)
class ShardCreateFacebaseFriends < ActiveRecord::Migration
  def change
    create_table :facebase_friends do |t|
      t.integer :profile_id, :null =>false
      t.integer :friends_profile_id , :null =>false
      t.integer :priority, :default => 50, :null => false

      #Friendlist data
      t.boolean :is_family, :default => false, :null => false
      t.boolean :is_close_friend, :default => false, :null => false
      t.boolean :is_user_created, :default => false, :null => false
      t.boolean :is_restricted, :default => false, :null => false
      t.boolean :is_acquaintance, :default => false, :null => false
      t.boolean :is_school_friend, :default => false, :null => false
      t.boolean :is_coworker, :default => false, :null => false
      t.boolean :is_in_current_city, :default => false, :null => false
      t.boolean :is_matching_last_name, :default => false, :null => false

      t.timestamps
    end

    # The shard key is  64bit bit int
    execute "ALTER TABLE facebase_friends MODIFY profile_id BIGINT UNSIGNED NOT NULL"
    execute "ALTER TABLE facebase_friends MODIFY friends_profile_id BIGINT UNSIGNED NOT NULL"


    add_index :facebase_friends, [:friends_profile_id, :profile_id], :unique => true
    add_index :facebase_friends, [:profile_id, :priority]
    add_index :facebase_friends, :priority
  end
end
