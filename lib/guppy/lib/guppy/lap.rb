module Guppy
  class Lap

    @@attributes = [:avg_heart_rate, :avg_watts,        :max_watts,    :avg_cadence,
                    :max_cadence,    :calories,         :distance,     :intensity,
                    :max_heart_rate, :avg_speed,        :max_speed,    :start_time,
                    :total_time,     :elevation_gain, :elevation_loss, :kjoules, 
                    :ride_time, :total_trackpoints ]

    attr_accessor *@@attributes
    attr_accessor :track_points
  
    def initialize
      @track_points = []
      zero_all_attrs
    end
  
    def zero_all_attrs
      @@attributes.each do |a|
        instance_variable_set "@#{a}", 0
      end
    end

    def elapsed(current_thing,past_thing)
      current_thing - past_thing
    end

    def to_hash
     @@attributes.each_with_object({}) { 
        |a,h| h[a] = instance_variable_get "@#{a}" 
      }
    end

    def calculate_and_cache_attributes

      last_time = 0
      last_distance = 0
      last_altitude = 0
   
      track_points.each do |track_point|

      @total_trackpoints += 1

      # Initialize 
      last_time=track_point.time if last_time == 0
      last_distance=track_point.distance if last_distance == 0
      last_altitude=track_point.altitude if last_altitude == 0

      # Joules
      @kjoules += (track_point.watts*elapsed(track_point.time,last_time))/1000
      
      # Ride Time
      if( elapsed(track_point.distance,last_distance) > 0 || 
          track_point.cadence > 0 || 
          track_point.watts > 0 )
        @ride_time += elapsed(track_point.time,last_time) 
      end

      # Elevation
      if last_altitude <= track_point.altitude
        @elevation_gain += (track_point.altitude - last_altitude)
      else
        @elevation_loss += (last_altitude - track_point.altitude)
      end 

      last_time=track_point.time
      last_distance=track_point.distance      
      last_altitude=track_point.altitude
    
    end 

  end
  
  end
end
