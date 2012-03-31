class CreateFacebaseShards < ActiveRecord::Migration
  def change
    create_table :facebase_shards do |t|
      # Using preallocation of a huge range we cut shards accordingly
      t.column(:auto_increment_start, "BIGINT UNSIGNED", {:null => false})
      t.column(:auto_increment_range, "BIGINT UNSIGNED", {:null => false})
      t.boolean :initialized, :default => false, :null => false

      t.text :host
      t.string :socket
      t.string :adapter, :null => false
      t.string :username, :null => false
      t.string :password, :null => false
      t.string :database, :null => false
      t.integer :port
      t.integer :pool, :default => 5, :null => false
      t.string :encoding, :default => "utf8", :null => false
      t.boolean :reconnect, :default => false, :null => false

      # The principle modle we are sharding on
      t.string :principle_model, :null => false

      t.timestamps
    end

  end
end
