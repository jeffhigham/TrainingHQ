class Activity < ActiveRecord::Base

  attr_accessible :garmin_activity_id, :creator_name, :product_id, :sport, :unit_id, :datafile, 
                  :author_name, :activity_date, :name, :user_id, :processed, :status, 
                  :elevation_gain, :elevation_loss, :kjoules, :total_laps, :total_trackpoints, 
                  :ride_time, :distance, :max_watts, :min_watts, :avg_watts, :max_heart_rate,
                  :min_heart_rate, :avg_heart_rate, :max_cadence, :min_cadence, :avg_cadence,
                  :max_temp, :min_temp, :avg_temp, :max_speed, :min_speed, :avg_speed, :calories
                  
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

  #def max_watts
  #	max_watts = 0
  #	self.laps.each do |lap|
  #		max_watts = lap.max_watts unless lap.max_watts < max_watts
  #	end
  #	return max_watts
  #end

  #def min_watts
  #	min_watts = 10000 # something way too high.
  #	self.laps.each do |lap|
  #		min_watts = lap.min_watts unless lap.min_watts > min_watts
  #	end
  #	return min_watts
  #end

  #def avg_watts
  #	bunch_of_watts = []
  #	self.laps.each do |lap|
  #		bunch_of_watts << lap.avg_watts
  #	end
  #	return (bunch_of_watts.sum/bunch_of_watts.count)
  #end

  #def avg_heart_rate
  #  bunch_of_hr = []
  #  self.laps.each do |lap|
  #    bunch_of_hr << lap.avg_heart_rate
  #  end
  #  return (bunch_of_hr.sum/bunch_of_hr.count)
  #end

  #def avg_cadence
  #  bunch_of_cadence = []
  #  self.laps.each do |lap|
  #    bunch_of_cadence << lap.avg_cadence
  #  end
  #  return (bunch_of_cadence.sum/bunch_of_cadence.count)
  # end

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

  def raw_numbers
    power_numbers_time = []
    power_numbers_distance = []

    heart_rate_numbers_time = []
    heart_rate_numbers_distance = []

    cadence_numbers_time = []
    cadence_numbers_distance = []

    altitude_numbers_time = []
    altitude_numbers_distance = []

    lap_numbers_time = []
    #json = []
    #points = []
    last_trackpoint_distance = 0;
    self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        # Time-based numbers, record every trackpoint.
        power_numbers_time << trackpoint.watts
        heart_rate_numbers_time << trackpoint.heart_rate
        cadence_numbers_time << trackpoint.cadence
        altitude_numbers_time << trackpoint.altitude_feet

        # Distance-based numbers, record only if moving.
        if (trackpoint.distance - last_trackpoint_distance) > 0
          power_numbers_distance << trackpoint.watts
          heart_rate_numbers_distance << trackpoint.heart_rate
          cadence_numbers_distance << trackpoint.cadence
          altitude_numbers_distance << trackpoint.altitude_feet
          last_trackpoint_distance = trackpoint.distance
        end

     #   unless  trackpoint.longitude === 0 or trackpoint.latitude === 0
     #    points  << { lng: trackpoint.longitude,lat: trackpoint.latitude }
     #   end

      end
    end
      ( power_numbers_time = [0] && power_numbers_distance = [0] ) if power_numbers_time.max == 0
      ( cadence_numbers_time = [0] && cadence_numbers_distance = [0] ) if cadence_numbers_time.max == 0
      ( heart_rate_numbers_time = [0] && heart_rate_numbers_distance = [0] ) if heart_rate_numbers_time.max == 0
      ( altitude_numbers_time = [0] && altitude_numbers_distance = [0] ) if altitude_numbers_time.max == 0
    #  json << points

     {
      :power_numbers_time => power_numbers_time,
      :power_numbers_distance => power_numbers_distance,
      :heart_rate_numbers_time => heart_rate_numbers_time,
      :heart_rate_numbers_distance => heart_rate_numbers_distance,
      :cadence_numbers_time => cadence_numbers_time,
      :cadence_numbers_distance => cadence_numbers_distance,
      :altitude_numbers_time => altitude_numbers_time,
      :altitude_numbers_distance => altitude_numbers_distance
   #   :map_data => json.to_json
    }

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