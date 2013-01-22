class AddPrecisionToActivityStatus < ActiveRecord::Migration
  def change
  			remove_column :activities, :status
  	  	add_column :activities, :status, :decimal, :precision => 23, :scale => 20
  end
end
