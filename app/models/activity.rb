class Activity < ActiveRecord::Base

  attr_accessible :garmin_activity_id, :creator_name, :product_id, :sport, :unit_id, :datafile, 
                  :author_name, :activity_date, :name, :user_id, :processed, :status, 
                  :elevation_gain, :elevation_loss, :kjoules, :total_laps, :total_trackpoints, 
                  :ride_time, :distance, :max_watts, :min_watts, :avg_watts, :max_heart_rate,
                  :min_heart_rate, :avg_heart_rate, :max_cadence, :min_cadence, :avg_cadence,
                  :max_temp, :min_temp, :avg_temp, :max_speed, :min_speed, :avg_speed, :calories,
                  :max_altitude, :min_altitude, :avg_altitude, :start_time, :total_time, :intensity
                  
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

  def total_time_formatted
    time_formatted(self.total_time.to_i)  # fix total_time data type!! string -> int
  end

  def ride_time_formatted
    time_formatted(self.ride_time)
  end

  def distance_miles
    distance_meters_to_miles(self.distance)
  end

  def distance_feet
    distance_meters_to_feet(self.distance)
  end

  def elevation_feet
    distance_meters_to_feet(self.elevation_gain)
  end

  def max_speed_mph
    speed_kmph_to_mph(self.max_speed)
  end

  def avg_speed_mph
    speed_kmph_to_mph(self.avg_speed)
  end

  def javascript_data

    # creates datastructures to use for maps and graphs.

    power_numbers_time = []
    power_numbers_distance = []

    heart_rate_numbers_time = []
    heart_rate_numbers_distance = []

    cadence_numbers_time = []
    cadence_numbers_distance = []

    altitude_numbers_time = []
    altitude_numbers_distance = []

    speed_numbers_time = []
    speed_numbers_distance = []

    distance_numbers = []
    time_numbers = []

    laps_time = []
    laps_distance = []

    lap_numbers_time = []
    lap_numbers_distance = []

    last_trackpoint_distance = 0;

    self.laps.each do |lap|

      lap.trackpoints.each do |trackpoint|
        # Time-based numbers, record every trackpoint.
        power_numbers_time << trackpoint.watts
        heart_rate_numbers_time << trackpoint.heart_rate
        cadence_numbers_time << trackpoint.cadence
        altitude_numbers_time << trackpoint.altitude_feet
        speed_numbers_time << trackpoint.speed.to_f
        distance_numbers << trackpoint.distance
        time_numbers << trackpoint.time

        # Distance-based numbers, record only if moving.
        if (trackpoint.distance - last_trackpoint_distance) > 0
          power_numbers_distance << trackpoint.watts
          heart_rate_numbers_distance << trackpoint.heart_rate
          cadence_numbers_distance << trackpoint.cadence
          altitude_numbers_distance << trackpoint.altitude_feet
          speed_numbers_distance << trackpoint.speed.to_f
          last_trackpoint_distance = trackpoint.distance
        end

      end

      ( power_numbers_time = [0] && power_numbers_distance = [0] ) if power_numbers_time.max == 0
      ( cadence_numbers_time = [0] && cadence_numbers_distance = [0] ) if cadence_numbers_time.max == 0
      ( heart_rate_numbers_time = [0] && heart_rate_numbers_distance = [0] ) if heart_rate_numbers_time.max == 0
      ( altitude_numbers_time = [0] && altitude_numbers_distance = [0] ) if altitude_numbers_time.max == 0
      ( speed_numbers_time = [0] && speed_numbers_distance = [0] ) if speed_numbers_time.max == 0


      lap_numbers_time << {
        :power_numbers_time => power_numbers_time,
        :heart_rate_numbers_time => heart_rate_numbers_time,
        :cadence_numbers_time => cadence_numbers_time,
        :altitude_numbers_time => altitude_numbers_time,
        :speed_numbers_time => speed_numbers_time,
        :time => time_numbers
      }

      lap_numbers_distance << {
        :power_numbers_distance => power_numbers_distance,
        :heart_rate_numbers_distance => heart_rate_numbers_distance,
        :cadence_numbers_distance => cadence_numbers_distance,
        :altitude_numbers_distance => altitude_numbers_distance,
        :speed_numbers_distance => speed_numbers_distance,
        :distance => distance_numbers
      }
      
    end
    
     {
      :power_numbers_time => power_numbers_time,
      :power_numbers_distance => power_numbers_distance,
      :heart_rate_numbers_time => heart_rate_numbers_time,
      :heart_rate_numbers_distance => heart_rate_numbers_distance,
      :cadence_numbers_time => cadence_numbers_time,
      :cadence_numbers_distance => cadence_numbers_distance,
      :altitude_numbers_time => altitude_numbers_time,
      :altitude_numbers_distance => altitude_numbers_distance,
      :speed_numbers_time => speed_numbers_time,
      :speed_numbers_distance => speed_numbers_distance,
      :lap_numbers_time => lap_numbers_time,
      :lap_numbers_distance => lap_numbers_distance
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