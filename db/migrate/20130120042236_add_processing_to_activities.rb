class AddProcessingToActivities < ActiveRecord::Migration
  def change
  	add_column :activities, :processed, :boolean , :default => 0
  	add_column :activities, :status, :integer, :default => 0
  end
end
