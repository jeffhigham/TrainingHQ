class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :sport
      t.string :activityid
      t.string :creatorname
      t.string :unitid
      t.string :productid

      t.timestamps
    end
  end
end
