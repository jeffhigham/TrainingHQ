class AddNotesToActivities < ActiveRecord::Migration
  def change
  	add_column :activities, :notes, :text, :default => ""
  end
end
