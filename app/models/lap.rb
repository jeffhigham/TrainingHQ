class Lap < ActiveRecord::Base
  attr_accessible :ave_heart_rate, :ave_watts, :max_watts, :ave_cadence, :max_cadence, :calories, 
                  :distance, :intensity, :max_heart_rate, :ave_speed, :max_speed, :start_time, :total_time

  belongs_to :activity
  has_many :trackpoints, dependent: :destroy

  def min_heart_rate
  	min_heart_rate = 500 # something way too high.
  	self.trackpoints.each do |trackpoint|
  		min_heart_rate = trackpoint.heart_rate unless trackpoint.heart_rate > min_heart_rate
  	end
  	return min_heart_rate
  end

  def get_max_watts

    return self.max_watts if self.max_watts > 0
  	
    max_watts = 0
  	self.trackpoints.each do |trackpoint|
  		max_watts = trackpoint.watts unless trackpoint.watts < max_watts
  	end
  	return max_watts
  end

  def min_watts
  	min_watts = 10000 # something way too high.
  	self.trackpoints.each do |trackpoint|
  		min_watts = trackpoint.watts unless trackpoint.watts > min_watts
  	end
  	return min_watts
  end

  def get_max_cadence

    return self.max_cadence if self.max_cadence > 0

  	max_cadence = 0
  	self.trackpoints.each do |trackpoint|
  		max_cadence = trackpoint.cadence unless trackpoint.cadence < max_cadence
  	end
  	return max_cadence
  end

  def min_cadence
  	min_cadence = 10000 # something way too high.
  	self.trackpoints.each do |trackpoint|
  		min_cadence = trackpoint.cadence unless trackpoint.cadence > min_cadence
  	end
  	return min_cadence
  end

  def min_power_zone
  	return power_zone(self.min_watts)
  end

  def ave_power_zone
  	return power_zone(self.ave_watts)
  end

  def max_power_zone
  	return power_zone(self.max_watts)
  end

  def distance_feet
  	return (self.distance * 3.281).round(1)	
  end

  def altitude_feet
  	return (self.altitude * 3.281).round(1)
  end

	def power_zone_ranges
		z1 = (0..152)
  	z2 = (153..208)
  	z3 = (209..250)  		
  	z4 = (251..292)
 		z5 = (293..234)
 		z6 = (235..417)
  	z7 = (418..2000)
  	return [ z1, z2, z3, z4, z5, z6, z7]
	end

  def power_zone(watts)
   	power_zones = self.power_zone_ranges
  	power_zones.each do |zone_range|
  		return power_zones.index(zone_range)+1 if zone_range.include?(watts)
  	end
  end

end
