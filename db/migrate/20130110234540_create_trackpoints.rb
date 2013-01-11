class CreateTrackpoints < ActiveRecord::Migration
  def change
    create_table :trackpoints do |t|
      t.integer :lap_id
      t.string :time
      t.decimal :latitudedegrees
      t.decimal :longitudedegrees
      t.decimal :altitudemeters
      t.decimal :distancemeters
      t.integer :heartratebpm
      t.integer :cadence
      t.integer :watts

      t.timestamps
    end
  end
end
