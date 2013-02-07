class FixLapsTable < ActiveRecord::Migration
  def up
  	rename_column :laps, :agv_speed, :avg_speed
  	rename_column :laps, :agv_heart_rate, :avg_heart_rate
  	rename_column :laps, :agv_cadence, :avg_cadence
  	rename_column :laps, :agv_watts, :avg_watts
  end

  def down
  end
end
