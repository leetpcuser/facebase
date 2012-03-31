# This migration comes from facebase (originally 20120305044350)
class ShardCreateFacebaseProfiles < ActiveRecord::Migration
  def change
    create_table :facebase_profiles, {:id => false} do |t|
      # Facebook profile information
      t.integer :facebook_id
      t.string :name
      t.string :first_name
      t.string :last_name
      t.integer :birth_year
      t.integer :birth_month
      t.integer :birth_day_of_month
      t.string :gender
      t.string :relationship_status
      t.string :religion
      t.string :political
      t.string :timezone
      t.string :locale
      t.string :hometown
      t.string :location

      t.timestamps
    end

    # Provides the 64 bit integer space for fid
    execute "ALTER TABLE facebase_profiles MODIFY facebook_id BIGINT UNSIGNED NOT NULL"
    # Provides the 64 bit integer space for our primary key
    execute "ALTER TABLE facebase_profiles ADD id BIGINT UNSIGNED DEFAULT NULL auto_increment PRIMARY KEY"

    # Direct key value lookup accelerators
    add_index :facebase_profiles, :facebook_id, :unique => true
    add_index :facebase_profiles, [:birth_day_of_month, :birth_month, :birth_year], :name => :birthday_index

  end
end
