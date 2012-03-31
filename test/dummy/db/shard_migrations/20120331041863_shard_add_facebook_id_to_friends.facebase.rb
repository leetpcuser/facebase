# This migration comes from facebase (originally 20120317165335)
class ShardAddFacebookIdToFriends < ActiveRecord::Migration
  def up
    # Useful for corruption protection. Reconstruction of profile_ids
    # can be made if profile data is accidentally duplicated across shards
    # by removing duplicates and then looking for the facebook_id
    add_column :facebase_friends, :facebook_id, :integer

    # The shard key is  64bit bit int
    execute "ALTER TABLE facebase_friends MODIFY facebook_id BIGINT UNSIGNED NOT NULL"
  end

  def down
  end
end
