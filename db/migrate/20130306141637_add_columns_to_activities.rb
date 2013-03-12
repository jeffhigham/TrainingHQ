class AddColumnsToActivities < ActiveRecord::Migration
  def change
  	add_column :activities, :max_watts, :integer, :default => 0
  	add_column :activities, :min_watts, :integer, :default => 0
  	add_column :activities, :avg_watts, :integer, :default => 0
  	add_column :activities, :max_heart_rate, :integer, :default => 0
  	add_column :activities, :min_heart_rate, :integer, :default => 0
  	add_column :activities, :avg_heart_rate, :integer, :default => 0
  	add_column :activities, :max_cadence, :integer, :default => 0
  	add_column :activities, :min_cadence, :integer, :default => 0
  	add_column :activities, :avg_cadence, :integer, :default => 0
  	add_column :activities, :max_temp, :integer, :default => 0
  	add_column :activities, :min_temp, :integer, :default => 0
  	add_column :activities, :avg_temp, :integer, :default => 0
  	add_column :activities, :max_speed, :integer, :default => 0
  	add_column :activities, :min_speed, :integer, :default => 0
  	add_column :activities, :avg_speed, :integer, :default => 0
  	add_column :activities, :calories, :integer, :default => 0

  end
end

# attr_accessible :max_watts, :min_watts, :avg_watts
  #                 :max_heart_rate, :min_heart_rate, :avg_heart_rate,
  #                 :max_cadence, :min_cadence, :avg_cadence,
  #                 :max_temp, :min_temp, avg_temp,
  #                 :max_speed, :min_speed, avg_speed,
  #                 :calories