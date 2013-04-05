class AddEvenMoreColumns < ActiveRecord::Migration
  def up
  	add_column :laps, :min_watts, :integer, :default => 0
  end

  def down
  end
end
