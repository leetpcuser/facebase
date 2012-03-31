# This migration comes from facebase (originally 20120305164126)
class ShardCreateFacebaseEmails < ActiveRecord::Migration
  def change
    create_table :facebase_emails do |t|

      # Email Base fields
      t.string :to
      t.string :from
      t.string :subject
      t.string :reply_to
      t.text :headers
      t.text :template_values

      # Foreign Key Relationships
      t.integer :email_service_provider_id, :null => false
      t.integer :contact_id, :null => false

      # Campaign setup
      t.string :campaign, :null =>false
      t.string :stream, :null => false
      t.string :component, :null => false

      # Processing data
      t.datetime :schedule_at
      t.boolean :pruned, :default => false, :null => false
      t.boolean :locked, :default => false, :null => false
      t.boolean :sent, :default => false, :null => false
      t.boolean :failed, :default => false, :null => false
      t.text :error_message
      t.text :error_backtrace

      # Google Analytics data
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :utm_term
      t.string :utm_content


      t.timestamps
    end

    add_index :facebase_emails, :contact_id
    add_index :facebase_emails, [:campaign, :stream, :component]

  end
end
