# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120331041868) do

  create_table "facebase_campaigns", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "facebase_components", :force => true do |t|
    t.string   "name"
    t.string   "suffix"
    t.text     "uri"
    t.boolean  "editable"
    t.integer  "stream_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "facebase_email_service_providers", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "port"
    t.string   "domain"
    t.string   "user_name"
    t.string   "password"
    t.string   "authentication"
    t.boolean  "enable_starttls_auto"
    t.boolean  "enable_sendgrid_tracking"
    t.boolean  "enable_auto_google_analytics"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "facebase_shards", :force => true do |t|
    t.integer  "auto_increment_start", :limit => 8,                     :null => false
    t.integer  "auto_increment_range", :limit => 8,                     :null => false
    t.boolean  "initialized",                       :default => false,  :null => false
    t.text     "host"
    t.string   "socket"
    t.string   "adapter",                                               :null => false
    t.string   "username",                                              :null => false
    t.string   "password",                                              :null => false
    t.string   "database",                                              :null => false
    t.integer  "port"
    t.integer  "pool",                              :default => 5,      :null => false
    t.string   "encoding",                          :default => "utf8", :null => false
    t.boolean  "reconnect",                         :default => false,  :null => false
    t.string   "principle_model",                                       :null => false
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  create_table "facebase_streams", :force => true do |t|
    t.string   "name"
    t.integer  "campaign_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
