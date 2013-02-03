class Activity < ActiveRecord::Base

  attr_accessible :activityid, :creator_name, :product_id, :sport, :unit_id, :datafile, 
                  :author_name, :activity_date, :name, :user_id, :processed, :status, 
                  :elevation_gain, :elevation_loss, :kjoules
  has_attached_file :datafile
  has_many :laps, dependent: :destroy
  belongs_to :user

  require "./lib/shared_methods.rb"
  include SharedMethods

  def elevation_loss_feet
    return distance_meters_to_feet(self.elevation_loss)
  end

  def elevation_gain_feet
    return distance_meters_to_feet(self.elevation_gain)
  end

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

  def avg_watts
  	bunch_of_watts = []
  	self.laps.each do |lap|
  		bunch_of_watts << lap.ave_watts
  	end
  	return (bunch_of_watts.sum/bunch_of_watts.count)
  end

  def avg_heart_rate
    bunch_of_hr = []
    self.laps.each do |lap|
      bunch_of_hr << lap.ave_heart_rate
    end
    return (bunch_of_hr.sum/bunch_of_hr.count)
  end

  def avg_cadence
    bunch_of_cadence = []
    self.laps.each do |lap|
      bunch_of_cadence << lap.ave_cadence
    end
    return (bunch_of_cadence.sum/bunch_of_cadence.count)
  end

  def total_time_formatted
    time_in_seconds = 0
    self.laps.each do |lap|
      time_in_seconds += lap.total_time
    end
    return time_formatted(time_in_seconds)
  end

  def ride_time_formatted
    time_in_seconds = 0
    self.laps.each do |lap|
      time_in_seconds += lap.ride_time
    end
    return time_formatted(time_in_seconds)
  end

  def total_distance_formatted
    return ride_distance_formatted(distance_meters_to_feet(self.distance_meters)).round(2)
  end

  def distance_meters
    distance_meters = 0
    self.laps.each do |lap|
      distance_meters += lap.distance
    end
    return distance_meters
  end

  def power_numbers
    power_numbers_list = []
    self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        power_numbers_list << trackpoint.watts
      end
    end
    power_numbers_list
  end

  def heart_rate_numbers
    heart_rate_list = []
    self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        heart_rate_list << trackpoint.heart_rate
      end
    end
    heart_rate_list
  end

  def cadence_numbers
    cadence_list = []
    self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        cadence_list << trackpoint.cadence
      end
    end
    cadence_list
  end

  def altitude_numbers
    altitude_list = []
    self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        altitude_list << trackpoint.altitude_feet
      end
    end
    altitude_list
  end

  def map_data

    json = []
    points = []
      self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        unless  trackpoint.longitude === 0 or trackpoint.latitude === 0
          points  << { lng: trackpoint.longitude,lat: trackpoint.latitude }
        end
      end
    end
    json << points
    return json.to_json
  end

end