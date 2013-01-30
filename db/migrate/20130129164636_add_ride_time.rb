class AddRideTime < ActiveRecord::Migration
  def up
  	add_column :laps, :ride_time, :integer, :default => 0
  end

  def down
  end
end
