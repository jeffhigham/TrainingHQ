class AddTotalTrackpointsToLaps < ActiveRecord::Migration
  def change
  	add_column :laps, :total_trackpoints, :integer, :default => 0
  end
end
