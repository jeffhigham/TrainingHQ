class AddActivityIdToLap < ActiveRecord::Migration
  def change
    add_column :laps, :activity_id, :integer
  end
end
