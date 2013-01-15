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

ActiveRecord::Schema.define(:version => 20130110234540) do

  create_table "activities", :force => true do |t|
    t.string   "activity_date"
    t.string   "sport"
    t.string   "activityid"
    t.string   "creator_name"
    t.string   "unit_id"
    t.string   "product_id"
    t.string   "author_name"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "datafile_file_name"
    t.string   "datafile_content_type"
    t.integer  "datafile_file_size"
    t.datetime "datafile_updated_at"
  end

  create_table "laps", :force => true do |t|
    t.string   "start_time"
    t.decimal  "total_time",     :precision => 10, :scale => 0
    t.decimal  "distance",       :precision => 10, :scale => 0
    t.decimal  "ave_speed",      :precision => 10, :scale => 0
    t.decimal  "max_speed",      :precision => 10, :scale => 0
    t.integer  "calories"
    t.integer  "ave_heart_rate"
    t.integer  "max_heart_rate"
    t.string   "intensity"
    t.integer  "ave_cadence"
    t.integer  "max_cadence"
    t.integer  "ave_watts"
    t.integer  "max_watts"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "activity_id"
  end

  create_table "trackpoints", :force => true do |t|
    t.integer  "lap_id"
    t.string   "time"
    t.decimal  "latitude",   :precision => 10, :scale => 0
    t.decimal  "longitude",  :precision => 10, :scale => 0
    t.decimal  "altitude",   :precision => 10, :scale => 0
    t.decimal  "distance",   :precision => 10, :scale => 0
    t.integer  "heart_rate"
    t.integer  "cadence"
    t.integer  "watts"
    t.decimal  "speed",      :precision => 10, :scale => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

end
