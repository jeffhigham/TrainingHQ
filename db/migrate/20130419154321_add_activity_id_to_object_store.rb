class AddActivityIdToObjectStore < ActiveRecord::Migration
  def change
  	add_column :object_stores, :activity_id, :integer
  end
end
