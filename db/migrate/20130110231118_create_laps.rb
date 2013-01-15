class CreateLaps < ActiveRecord::Migration
  def change
    create_table :laps do |t|
      t.string  :start_time
      t.decimal :total_time
      t.decimal :distance
      t.decimal :ave_speed
      t.decimal :max_speed
      t.integer :calories
      t.integer :ave_heart_rate
      t.integer :max_heart_rate
      t.string  :intensity
      t.integer :ave_cadence
      t.integer :max_cadence
      t.integer :ave_watts
      t.integer :max_watts

      t.timestamps
    end
  end
end
