class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :activity_date
      t.string :sport
      t.string :activityid
      t.string :creator_name
      t.string :unit_id
      t.string :product_id
      t.string :author_name
      t.timestamps
    end
  end
end
