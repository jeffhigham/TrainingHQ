class AddWeightToUsers < ActiveRecord::Migration
  def change
    add_column :users, :weight, :integer, :default => 150
  end
end
