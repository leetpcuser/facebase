class ShardCreateFacebaseEmailActions < ActiveRecord::Migration
  def change
    create_table :facebase_email_actions do |t|
      t.integer :email_id
      t.string :action_type
      t.integer :count
      t.text :details
      t.timestamps
    end
  end
end
