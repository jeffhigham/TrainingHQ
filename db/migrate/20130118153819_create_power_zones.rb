class CreatePowerZones < ActiveRecord::Migration
  def change
    create_table :power_zones do |t|
      t.integer :user_id
      t.integer :z0
      t.integer :z1
      t.integer :z2
      t.integer :z3
      t.integer :z4
      t.integer :z5
      t.integer :z6
      t.integer :z7
      t.boolean :enabled

      t.timestamps
    end
  end
end
