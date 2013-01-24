class AddElevationLossGainToActivityAndLap < ActiveRecord::Migration
  def change
  	add_column :laps, :elevation_loss, :integer, :default => 0
  	add_column :laps, :elevation_gain, :integer, :default => 0
		add_column :activities, :elevation_loss, :integer, :default => 0
  	add_column :activities, :elevation_gain, :integer, :default => 0
  end
end
