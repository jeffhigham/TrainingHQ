class CreateTrackpoints < ActiveRecord::Migration
  def change
    create_table :trackpoints do |t|
      t.integer :lap_id
      t.string  :time
      t.decimal :latitude
      t.decimal :longitude
      t.decimal :altitude
      t.decimal :distance
      t.integer :heart_rate
      t.integer :cadence
      t.integer :watts
      t.decimal :speed

      t.timestamps
    end
  end
end
