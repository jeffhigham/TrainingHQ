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

ActiveRecord::Schema.define(:version => 20130331025133) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id",                                               :default => 0
    t.string   "activity_date"
    t.string   "sport"
    t.string   "garmin_activity_id"
    t.string   "creator_name"
    t.string   "unit_id"
    t.string   "product_id"
    t.string   "author_name"
    t.string   "datafile_file_name"
    t.string   "datafile_content_type"
    t.integer  "datafile_file_size"
    t.datetime "datafile_updated_at"
    t.string   "name",                                                  :default => "New Activity"
    t.boolean  "processed",                                             :default => false
    t.decimal  "status",                :precision => 23, :scale => 20
    t.integer  "elevation_loss",                                        :default => 0
    t.integer  "elevation_gain",                                        :default => 0
    t.integer  "kjoules",                                               :default => 0
    t.text     "notes"
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
    t.integer  "total_laps"
    t.integer  "ride_time"
    t.integer  "total_trackpoints"
    t.integer  "distance"
    t.integer  "max_watts",                                             :default => 0
    t.integer  "min_watts",                                             :default => 0
    t.integer  "avg_watts",                                             :default => 0
    t.integer  "max_heart_rate",                                        :default => 0
    t.integer  "min_heart_rate",                                        :default => 0
    t.integer  "avg_heart_rate",                                        :default => 0
    t.integer  "max_cadence",                                           :default => 0
    t.integer  "min_cadence",                                           :default => 0
    t.integer  "avg_cadence",                                           :default => 0
    t.integer  "max_temp",                                              :default => 0
    t.integer  "min_temp",                                              :default => 0
    t.integer  "avg_temp",                                              :default => 0
    t.integer  "max_speed",                                             :default => 0
    t.integer  "min_speed",                                             :default => 0
    t.integer  "avg_speed",                                             :default => 0
    t.integer  "calories",                                              :default => 0
    t.integer  "max_altitude",                                          :default => 0
    t.integer  "min_altitude",                                          :default => 0
    t.integer  "avg_altitude",                                          :default => 0
    t.string   "start_time"
    t.string   "total_time"
    t.string   "intensity"
  end

  create_table "hr_zones", :force => true do |t|
    t.integer  "user_id"
    t.integer  "z0"
    t.integer  "z1"
    t.integer  "z2"
    t.integer  "z3"
    t.integer  "z4"
    t.integer  "z5"
    t.integer  "z6"
    t.integer  "z7"
    t.boolean  "enabled",    :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "journal_entries", :force => true do |t|
    t.integer  "user_id"
    t.string   "category"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "laps", :force => true do |t|
    t.integer  "activity_id"
    t.string   "start_time"
    t.decimal  "total_time",        :precision => 10, :scale => 0
    t.decimal  "distance",          :precision => 10, :scale => 0
    t.decimal  "avg_speed",         :precision => 10, :scale => 0
    t.decimal  "max_speed",         :precision => 10, :scale => 0
    t.integer  "calories",                                         :default => 0
    t.integer  "avg_heart_rate",                                   :default => 0
    t.integer  "max_heart_rate",                                   :default => 0
    t.string   "intensity",                                        :default => "unknown"
    t.integer  "avg_cadence",                                      :default => 0
    t.integer  "max_cadence",                                      :default => 0
    t.integer  "avg_watts",                                        :default => 0
    t.integer  "max_watts",                                        :default => 0
    t.integer  "elevation_loss",                                   :default => 0
    t.integer  "elevation_gain",                                   :default => 0
    t.integer  "kjoules",                                          :default => 0
    t.integer  "ride_time",                                        :default => 0
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.integer  "total_trackpoints",                                :default => 0
    t.integer  "min_heart_rate",                                   :default => 0
    t.integer  "min_cadence",                                      :default => 0
    t.integer  "max_temp",                                         :default => 0
    t.integer  "min_temp",                                         :default => 0
    t.integer  "avg_temp",                                         :default => 0
    t.integer  "min_speed",                                        :default => 0
    t.integer  "max_altitude",                                     :default => 0
    t.integer  "min_altitude",                                     :default => 0
    t.integer  "avg_altitude",                                     :default => 0
    t.integer  "min_watts",                                        :default => 0
  end

  create_table "power_zones", :force => true do |t|
    t.integer  "user_id"
    t.integer  "z0"
    t.integer  "z1"
    t.integer  "z2"
    t.integer  "z3"
    t.integer  "z4"
    t.integer  "z5"
    t.integer  "z6"
    t.integer  "z7"
    t.boolean  "enabled",    :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "trackpoints", :force => true do |t|
    t.integer  "lap_id"
    t.string   "time"
    t.decimal  "latitude",   :precision => 30, :scale => 20
    t.decimal  "longitude",  :precision => 30, :scale => 20
    t.decimal  "altitude",   :precision => 10, :scale => 2
    t.decimal  "distance",   :precision => 10, :scale => 2
    t.integer  "heart_rate",                                 :default => 0
    t.integer  "cadence",                                    :default => 0
    t.integer  "watts",                                      :default => 0
    t.decimal  "speed",      :precision => 5,  :scale => 2
    t.integer  "joules",                                     :default => 0
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "password_digest"
    t.boolean  "is_admin",            :default => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
