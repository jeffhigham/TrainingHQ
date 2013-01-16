class CreateTrackpoints < ActiveRecord::Migration
  def change
    create_table :trackpoints do |t|
      t.integer :lap_id
      t.string  :time
      t.decimal :latitude, :precision => 30, :scale => 20
      t.decimal :longitude, :precision => 30, :scale => 20
      t.decimal :altitude, :precision => 10, :scale => 2
      t.decimal :distance, :precision => 10, :scale => 2
      t.integer :heart_rate
      t.integer :cadence
      t.integer :watts
      t.decimal :speed, :precision => 5, :scale => 2

      t.timestamps
    end
  end
end
