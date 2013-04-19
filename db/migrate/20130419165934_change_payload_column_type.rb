class ChangePayloadColumnType < ActiveRecord::Migration
  def up
  	remove_column :object_stores, :payload
  	add_column :object_stores, :payload, :text
  end

  def down
  end
end
