class AddAltitudeMetrics < ActiveRecord::Migration
  def up
  	  	add_column :activities, :max_altitude, :integer, :default => 0
  			add_column :activities, :min_altitude, :integer, :default => 0
  			add_column :activities, :avg_altitude, :integer, :default => 0

  			add_column :laps, :max_altitude, :integer, :default => 0
  			add_column :laps, :min_altitude, :integer, :default => 0
  			add_column :laps, :avg_altitude, :integer, :default => 0
  end

  def down
  end
end
