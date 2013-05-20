module THQ
  class Lap

    @@attributes = [  :max_heart_rate, :min_heart_rate, :avg_heart_rate,
                      :max_watts, :min_watts, :avg_watts,
                      :max_cadence, :min_cadence, :avg_cadence,
                      :max_speed, :min_speed, :avg_speed,
                      :max_temp, :min_temp, :avg_temp,
                      :max_altitude, :min_altitude, :avg_altitude, 
                      :start_time, :total_time, :ride_time,
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
    # current lap. Her we also add additional attributes like percent_grade
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

      last_trackpoint_distance = 0
      last_trackpoint_altitude = 0
      percent_grade = 0
      trackpoint_percent_grade_rollover = 20 # number of samples to avg for %grade
      trackpoint_percent_grade_values = [0,0] # holds trackpoint_percent_grade_rollover values
      trackpoint_avg_percent_grade = 0 # average %grade based on trackpoint_percent_grade_rollover
   
      track_points.each do |track_point|
        # Initialize 
        last_time = track_point.time if last_time == 0
        last_distance = track_point.distance if last_distance == 0
        last_altitude = track_point.altitude if last_altitude == 0
        @min_watts = track_point.watts if @min_watts == 0
        @min_heart_rate = track_point.heart_rate if @min_heart_rate == 0
        @min_cadence = track_point.cadence if @min_cadence == 0
        @min_speed = track_point.speed.round(2) if @min_speed == 0
        @min_altitude = track_point.altitude.round(2) if @min_altitude == 0

        # % grade averaged over 20 trackpoints.
        # find percent grade if we actually traveled any distance. Otherwise it will remain 0 or last average calculation.
        if ( track_point.distance_feet - last_trackpoint_distance) > 0
         percent_grade = ( (track_point.altitude_feet - last_trackpoint_altitude) / (track_point.distance_feet - last_trackpoint_distance) )*100
        end

        # average out %grade values based on trackpoint_percent_grade_rollover
        trackpoint_avg_percent_grade = (trackpoint_percent_grade_values.inject{ |sum, el| sum + el }/trackpoint_percent_grade_values.count).round 
        # remove the oldest value if we have reached trackpoint_percent_grade_rollover
        trackpoint_percent_grade_values.shift if ( trackpoint_percent_grade_values.count == trackpoint_percent_grade_rollover )
        # add a new value to the array
        trackpoint_percent_grade_values << percent_grade
        # update the current trackpoint.
        track_point.percent_grade = trackpoint_avg_percent_grade

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

        @max_speed = track_point.speed.round(2) if track_point.speed > @max_speed
        @min_speed = track_point.speed.round(2) if track_point.speed < @min_speed
        total_speed  += track_point.speed

        @max_altitude = track_point.altitude.round(2) if track_point.altitude > @max_altitude
        @min_altitude = track_point.altitude.round(2) if track_point.altitude < @min_altitude
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

      @avg_watts      = (total_watts / @total_trackpoints).round(0)
      @avg_heart_rate = (total_heart_rate / @total_trackpoints).round(0)
      @avg_cadence    = (total_cadence / @total_trackpoints).round(0)
      @avg_speed      = (total_speed / @total_trackpoints).round(2)
      @avg_altitude   = (total_altitude / @total_trackpoints).round(2)
      @elevation_gain = @elevation_gain.round(2)
      @elevation_loss = @elevation_loss.round(2)
      @kjoules        = @kjoules.round(2)
      @start_time     = track_points.first.time

    end
  
  end
end
