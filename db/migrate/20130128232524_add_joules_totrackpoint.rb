class AddJoulesTotrackpoint < ActiveRecord::Migration
  def up
  	add_column :trackpoints, :joules, :integer, :default => 0
  	add_column :laps, :kjoules, :integer, :default => 0
  	add_column :activities, :kjoules, :integer, :default => 0
  end

  def down
  end
end
