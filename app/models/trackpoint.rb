class Trackpoint < ActiveRecord::Base
  attr_accessible :altitude, :cadence, :distance, :heart_rate, :latitude, 
  								:longitude, :time, :watts, :speed, :joules
  belongs_to :lap
 
 require "./lib/shared_methods.rb"
  include SharedMethods

  def distance_feet
  	return (self.distance * 3.281).round(1)	
  end

  def altitude_feet
  	return (self.altitude * 3.281).round(1)
  end

  def distance_miles
    distance_meters_to_miles(self.distance)
  end
  
end
