class CreateFacebaseCampaigns < ActiveRecord::Migration
  def change
    create_table :facebase_campaigns do |t|
      t.string :name

      t.timestamps
    end
  end
end
