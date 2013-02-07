class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer   :user_id, :default => 0      
      t.string    :activity_date
      t.string    :sport
      t.string    :garmin_activity_id
      t.string    :creator_name
      t.string    :unit_id
      t.string    :product_id
      t.string    :author_name
      t.string    :datafile_file_name
      t.string    :datafile_content_type
      t.integer   :datafile_file_size
      t.datetime  :datafile_updated_at
      t.string    :name, :default => "New Activity"
      t.boolean   :processed, :default => 0
      t.decimal   :status,:precision => 23, :scale => 20
      t.integer   :elevation_loss, :default => 0
      t.integer   :elevation_gain, :default => 0
      t.integer   :kjoules, :default => 0
      t.text      :notes

      t.timestamps
    end
  end


end
