class AddUserIdToActivities < ActiveRecord::Migration
  def change
  	add_column :activities, :user_id, :integer, :default => 0
  end
end
