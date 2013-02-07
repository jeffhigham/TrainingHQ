class CreateLaps < ActiveRecord::Migration
  def change
    create_table :laps do |t|
      t.integer  :activity_id
      t.string   :start_time 
      t.decimal  :total_time, :precision => 10, :scale => 0
      t.decimal  :distance, :precision => 10, :scale => 0
      t.decimal  :agv_speed, :precision => 10, :scale => 0
      t.decimal  :max_speed, :precision => 10, :scale => 0
      t.integer  :calories, :default => 0
      t.integer  :agv_heart_rate, :default => 0
      t.integer  :max_heart_rate, :default => 0
      t.string   :intensity, :default =>"unknown"
      t.integer  :agv_cadence, :default => 0
      t.integer  :max_cadence, :default => 0
      t.integer  :agv_watts, :default => 0
      t.integer  :max_watts, :default => 0
      t.integer  :elevation_loss, :default => 0
      t.integer  :elevation_gain, :default => 0
      t.integer  :kjoules, :default => 0
      t.integer  :ride_time, :default => 0

      t.timestamps
    end
  end
end
