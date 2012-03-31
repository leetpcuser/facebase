# This migration comes from facebase (originally 20120329182229)
class CreateFacebaseComponents < ActiveRecord::Migration
  def change
    create_table :facebase_components do |t|
      t.string :name
      t.string :suffix
      t.text :uri
      t.boolean :editable
      t.integer :stream_id

      t.timestamps
    end
  end
end
