class Trackpoint < ActiveRecord::Base
  attr_accessible :altitude, :cadence, :distance, :heart_rate, :latitude, :longitude, :time, :watts, :speed
  belongs_to :lap

  def distance_feet
  	return (self.distance * 3.281).round(1)	
  end

  def altitude_feet
  	return (self.altitude * 3.281).round(1)
  end
  
end
