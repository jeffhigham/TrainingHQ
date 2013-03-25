module Guppy
  class Lap

    @@attributes = [  :max_heart_rate, :min_heart_rate, :avg_heart_rate,
                      :max_watts, :min_watts, :avg_watts,
                      :max_cadence, :min_cadence, :avg_cadence,
                      :max_speed, :min_speed, :avg_speed,
                      :max_temp, :min_temp, :avg_temp,
                      :max_altitude, :min_altitude, :avg_altitude, 
                      :start_time, :total_time, :ride_time
                      :calories, :distance, :intensity,
                      :elevation_gain, :elevation_loss, :kjoules,
                      :total_trackpoints ]

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
     @@attributes.each_with_object({}) { |a,h| 
        h[a] = instance_variable_get "@#{a}" 
      }
    end

    # Given the large number of trackpoints in an activity we want to minimize
    # iterating over these a much as possible. This is an atempt to calculate
    # the useful data needed in a single loop through the trackpoints in the
    # current lap.
    #
    # This should be called before doing anything else with the object.
    #

    def calculate_and_cache_attributes

      last_time = 0
      last_distance = 0
      last_altitude = 0
      total_watts = 0
      total_heart_rate = 0
      total_cadence = 0
      total_speed = 0
      total_altitude = 0
   
      track_points.each do |track_point|
       
        # Initialize 
        last_time = track_point.time if last_time == 0
        last_distance = track_point.distance if last_distance == 0
        last_altitude = track_point.altitude if last_altitude == 0
        @min_watts = track_point.watts if @min_watts == 0
        @min_heart_rate = track_point.heart_rate if @min_heart_rate == 0
        @min_cadence = track_point.cadence if @min_cadence == 0
        @min_speed = track_point.speed if @min_speed == 0
        @min_altitude = track_point.altitude if @min_altitude == 0

        # Max/min watts, hr, cadence, speed, altitude, temp
        @max_watts = track_point.watts if track_point.watts > @max_watts
        @min_watts = track_point.watts if track_point.watts < @min_watts
        total_watts += track_point.watts

        @max_heart_rate = track_point.heart_rate if track_point.heart_rate > @max_heart_rate
        @min_heart_rate = track_point.heart_rate if track_point.heart_rate < @min_heart_rate
        total_heart_rate += track_point.heart_rate

        @max_cadence = track_point.cadence if track_point.cadence > @max_cadence
        @min_cadence = track_point.cadence if track_point.cadence < @min_cadence
        total_cadence += track_point.cadence

        @max_speed = track_point.speed if track_point.speed > @max_speed
        @min_speed = track_point.speed if track_point.speed < @min_speed
        total_speed  += track_point.speed

        @max_altitude = track_point.altitude if track_point.altitude > @max_altitude
        @min_altitude = track_point.altitude if track_point.altitude < @min_altigude
        total_altitude += track_point.altitude

        # track_point.temp has not been implemented yet. Initialized to 0
        #@max_temp = track_point.temp if track_point.temp > @max_temp
        #@min_temp = track_point.temp if track_point.temp < @min_temp


        # Joules watts * duration.
        @kjoules += (track_point.watts*elapsed(track_point.time,last_time))/1000
        
        # Increment ride time if we pedal or produce power. Distance is not 
        # used given the activity my be on a stationary trainer / rollers.
        if( elapsed(track_point.distance,last_distance) > 0 || 
            track_point.cadence > 0 || 
            track_point.watts > 0 )
          @ride_time += elapsed(track_point.time,last_time) 
        end

        # Elevation gain / loss
        if last_altitude <= track_point.altitude
          @elevation_gain += (track_point.altitude - last_altitude)
        else
          @elevation_loss += (last_altitude - track_point.altitude)
        end 

        last_time=track_point.time
        last_distance=track_point.distance      
        last_altitude=track_point.altitude
        @total_trackpoints += 1
    
      end 
      @avg_watts = total_watts / @total_trackpoints
      @avg_heart_rate = total_heart_rate / @total_trackpoints
      @avg_cadence = total_cadence / @total_trackpoints
      @avg_speed = total_speed / @total_trackpoints
      @avg_altitude = total_altitude / @total_trackpoints
      @start_time = trackpoints.first.time

    end
  
  end
end
