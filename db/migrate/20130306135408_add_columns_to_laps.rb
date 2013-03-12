class AddColumnsToLaps < ActiveRecord::Migration
  def change
        add_column :laps, :min_heart_rate, :integer, :default => 0
        add_column :laps, :min_cadence, :integer, :default => 0
        add_column :laps, :max_temp, :integer, :default => 0
        add_column :laps, :min_temp, :integer, :default => 0
        add_column :laps, :avg_temp, :integer, :default => 0
        add_column :laps, :min_speed, :integer, :default => 0

  end
end
