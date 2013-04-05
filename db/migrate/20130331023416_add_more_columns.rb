class AddMoreColumns < ActiveRecord::Migration
  def up
  	add_column :activities, :start_time, :string
  	add_column :activities, :total_time, :string
  	add_column :activities, :intensity, :string
  end

  def down
  end
end
