class Activity < ActiveRecord::Base
  attr_accessible :activityid, :creator_name, :product_id, :sport, :unit_id, :datafile, :author_name, :activity_date
  has_attached_file :datafile
  has_many :laps, dependent: :destroy


  def avg_watts
  	get_watts
  end

  def max_watts

  end


private

def get_watts
	
end


end
