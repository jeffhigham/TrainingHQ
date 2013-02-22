class Activity < ActiveRecord::Base

  attr_accessible :garmin_activity_id, :creator_name, :product_id, :sport, :unit_id, :datafile, 
                  :author_name, :activity_date, :name, :user_id, :processed, :status, 
                  :elevation_gain, :elevation_loss, :kjoules, :total_laps, :total_trackpoints, 
                  :ride_time, :distance
                  
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
  		bunch_of_watts << lap.avg_watts
  	end
  	return (bunch_of_watts.sum/bunch_of_watts.count)
  end

  def avg_heart_rate
    bunch_of_hr = []
    self.laps.each do |lap|
      bunch_of_hr << lap.avg_heart_rate
    end
    return (bunch_of_hr.sum/bunch_of_hr.count)
  end

  def avg_cadence
    bunch_of_cadence = []
    self.laps.each do |lap|
      bunch_of_cadence << lap.avg_cadence
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

  def max_values_by_percent(list,base_percent=0.0001)
    loop_count = 0
    max_loop_value = 0
    list_count = list.count
    loop_rollover = (list_count * base_percent).to_i
    return_list = []
    logger.info "\n\nloop_rollover = #{loop_rollover}"
    logger.info "list_count = #{list_count}"
    logger.info "base_percent = #{base_percent}\n\n"
    return list if loop_rollover <= 1 #too small to thin out dataset
    list.each do |item|
      max_loop_value = item unless item <= max_loop_value
      loop_count += 1
      if loop_count == loop_rollover
        return_list << max_loop_value
        loop_count = 0
        max_loop_value = 0
      end
    end
    return_list
  end

  def power_numbers
    power_numbers = []
    self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        power_numbers << trackpoint.watts
      end
    end
    max_values_by_percent power_numbers
  end

  def heart_rate_numbers
    heart_rate_list = []
    self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        heart_rate_list << trackpoint.heart_rate
      end
    end
    max_values_by_percent heart_rate_list
  end

  def cadence_numbers
    cadence_list = []
    self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        cadence_list << trackpoint.cadence
      end
    end
    max_values_by_percent cadence_list
  end

  def altitude_numbers
    altitude_list = []
    self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        altitude_list << trackpoint.altitude_feet
      end
    end
    max_values_by_percent altitude_list
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