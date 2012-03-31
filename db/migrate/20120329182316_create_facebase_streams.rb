class CreateFacebaseStreams < ActiveRecord::Migration
  def change
    create_table :facebase_streams do |t|
      t.string :name
      t.integer :campaign_id

      t.timestamps
    end
  end
end
