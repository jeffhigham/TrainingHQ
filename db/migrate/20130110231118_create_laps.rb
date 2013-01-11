class CreateLaps < ActiveRecord::Migration
  def change
    create_table :laps do |t|
      t.string :starttime
      t.decimal :totaltimeseconds
      t.decimal :distancemeters
      t.decimal :maximumspeed
      t.integer :calories
      t.integer :averageheartratebpm
      t.integer :maximumheartratebpm
      t.string :intensity
      t.integer :cadence
      t.integer :avgwatts

      t.timestamps
    end
  end
end
