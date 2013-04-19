class CreateObjectStores < ActiveRecord::Migration
  def change
    create_table :object_stores do |t|
      t.string :name
      t.binary :payload

      t.timestamps
    end
  end
end
