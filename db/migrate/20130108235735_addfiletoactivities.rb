class Addfiletoactivities < ActiveRecord::Migration
  def up
  	    add_attachment :activities, :datafile
  end

  def down
  end
end
