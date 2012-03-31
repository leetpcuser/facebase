class ShardCreateFacebaseContacts < ActiveRecord::Migration
  def change
    create_table :facebase_contacts do |t|
      t.integer :profile_id
      t.string :email_address
      t.string :phone
      t.decimal :purchase_total, :precision => 8, :scale => 2
      t.integer :purchase_count, :default => 0, :null => false
      t.boolean :unsubscribe_phone, :default => false, :null => false
      t.boolean :unsubscribe_facebook, :default => false, :null => false
      t.boolean :unsubscribed_email, :default => false, :null => false
      t.boolean :invalid_email, :default => false, :null => false
      t.boolean :spam_email, :default => false, :null => false
      t.boolean :bounced_email, :default => false, :null => false
      t.integer :emails_delivered, :default => 0, :null => false
      t.integer :times_emails_opened, :default => 0, :null => false
      t.integer :times_emails_clicked, :default => 0, :null => false
      t.datetime :last_contacted_at

      t.timestamps
    end

    # Provides the 64 bit integer space for profile_id
    execute "ALTER TABLE facebase_contacts MODIFY profile_id BIGINT UNSIGNED DEFAULT NULL"

    add_index :facebase_contacts,:profile_id, :unique => true
    add_index :facebase_contacts, :phone, :unique => true
    add_index :facebase_contacts, :email_address, :unique => true

  end
end

