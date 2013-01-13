class Activity < ActiveRecord::Base
  attr_accessible :activityid, :creator_name, :product_id, :sport, :unit_id, :datafile, :author_name, :activity_date
  has_attached_file :datafile
  has_many :laps, dependent: :destroy


  def max_watts
  	max_watts = 0
  	self.laps.each do |lap|
  		max_watts = lap.max_watts unless lap.max_watts < max_watts
  	end
  	return max_watts
  end

  def min_watts
  	min_watts = 10000 # something way too high.
  	self.laps.each do |lap|
  		min_watts = lap.min_watts unless lap.min_watts > min_watts
  	end
  	return min_watts
  end

  def ave_watts
  	bunch_of_watts = []
  	self.laps.each do |lap|
  		bunch_of_watts << lap.ave_watts
  	end
  	return (bunch_of_watts.sum/bunch_of_watts.count)
  end

end
