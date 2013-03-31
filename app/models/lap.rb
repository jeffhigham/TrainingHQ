class Lap < ActiveRecord::Base
  attr_accessible :max_heart_rate, :min_heart_rate, :avg_heart_rate,
                  :max_watts, :min_watts, :avg_watts,
                  :max_cadence, :min_cadence, :avg_cadence,
                  :max_speed, :min_speed, :avg_speed,
                  :max_temp, :min_temp, :avg_temp, 
                  :start_time, :total_time, :ride_time,
                  :calories, :distance, :intensity,
                  :elevation_gain, :elevation_loss, :kjoules,
                  :total_trackpoints, :max_altitude, :min_altitude, :avg_altitude

  belongs_to :activity
  has_many :trackpoints, dependent: :destroy

  require "./lib/shared_methods.rb"
  include SharedMethods

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

  #def min_watts
  #	min_watts = 10000 # something way too high.
  #	self.trackpoints.each do |trackpoint|
  #		min_watts = trackpoint.watts unless trackpoint.watts > min_watts
  #	end
  #	return min_watts
  #end

  def get_max_cadence

    return self.max_cadence if self.max_cadence > 0

  	max_cadence = 0
  	self.trackpoints.each do |trackpoint|
  		max_cadence = trackpoint.cadence unless trackpoint.cadence < max_cadence
  	end
  	return max_cadence
  end

  #def min_cadence
  #	min_cadence = 10000 # something way too high.
  #	self.trackpoints.each do |trackpoint|
  #		min_cadence = trackpoint.cadence unless trackpoint.cadence > min_cadence
  #	end
  #	return min_cadence
  #end

  def elevation_loss_feet
    return distance_meters_to_feet(self.elevation_loss)
  end

  def elevation_gain_feet
    return distance_meters_to_feet(self.elevation_gain)
  end

  def distance_feet
  	return distance_meters_to_feet(self.distance)	
  end

  def altitude_feet
  	return distance_meters_to_feet(self.altitude)
  end

  def total_time_formatted
      return time_formatted(total_time)
  end

  def total_distance_formatted
    return ride_distance_formatted(distance_meters_to_feet(self.distance)).round(2)
  end

end
