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
    t.string   "sport"
    t.string   "activityid"
    t.string   "creatorname"
    t.string   "unitid"
    t.string   "productid"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "datafile_file_name"
    t.string   "datafile_content_type"
    t.integer  "datafile_file_size"
    t.datetime "datafile_updated_at"
  end

  create_table "laps", :force => true do |t|
    t.string   "starttime"
    t.decimal  "totaltimeseconds"
    t.decimal  "distancemeters"
    t.decimal  "maximumspeed"
    t.integer  "calories"
    t.integer  "averageheartratebpm"
    t.integer  "maximumheartratebpm"
    t.string   "intensity"
    t.integer  "cadence"
    t.integer  "avgwatts"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "activity_id"
  end

  create_table "trackpoints", :force => true do |t|
    t.integer  "lap_id"
    t.string   "time"
    t.decimal  "latitudedegrees"
    t.decimal  "longitudedegrees"
    t.decimal  "altitudemeters"
    t.decimal  "distancemeters"
    t.integer  "heartratebpm"
    t.integer  "cadence"
    t.integer  "watts"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "workouts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "datafile_file_name"
    t.string   "datafile_content_type"
    t.integer  "datafile_file_size"
    t.datetime "datafile_updated_at"
  end

end
