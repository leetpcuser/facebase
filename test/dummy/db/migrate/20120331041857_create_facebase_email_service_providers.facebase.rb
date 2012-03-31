# This migration comes from facebase (originally 20120305170133)
class CreateFacebaseEmailServiceProviders < ActiveRecord::Migration
  def change
    create_table :facebase_email_service_providers do |t|
      t.string :name
      t.string :address
      t.integer :port
      t.string :domain
      t.string :user_name
      t.string :password
      t.string :authentication
      t.boolean :enable_starttls_auto
      t.boolean :enable_sendgrid_tracking
      t.boolean :enable_auto_google_analytics

      t.timestamps
    end
  end
end
