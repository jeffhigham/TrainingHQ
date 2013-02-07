class AddMissingToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :total_laps, :integer, :devault => 0
    add_column :activities, :ride_time, :integer, :devault => 0
    add_column :activities, :total_trackpoints, :integer, :devault => 0
    add_column :activities, :distance, :integer, :devault => 0
  end
end
