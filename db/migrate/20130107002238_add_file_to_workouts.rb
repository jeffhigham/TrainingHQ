class AddFileToWorkouts < ActiveRecord::Migration
  def change
    add_attachment :workouts, :datafile
  end
end
