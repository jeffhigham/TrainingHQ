module Guppy
  class Lap

    attr_accessor :avg_heart_rate
    attr_accessor :avg_watts
    attr_accessor :max_watts
    attr_accessor :avg_cadence
    attr_accessor :max_cadence
    attr_accessor :calories
    attr_accessor :distance
    attr_accessor :intensity
    attr_accessor :max_heart_rate
    attr_accessor :avg_speed
    attr_accessor :max_speed
    attr_accessor :start_tme
    attr_accessor :total_time
    attr_accessor :elevation_gain_c
    attr_accessor :elevation_loss_c
    attr_accessor :joules_c
    attr_accessor :ride_time_c
    attr_accessor :track_points
    
    def initialize
      @track_points = []
      @joules_c = 0
      @ride_time_c = 0
      @elevation_loss_c = 0
      @elevation_gain_c = 0
    end

  def total_trackpoints
      track_points.count
  end

  def ride_time
    @ride_time_c
  end

  def kjoules
    @joules_c/1000
  end

  def elevation_gain
    @elevation_gain_c
  end

  def elevation_loss
    @elevation_loss_c
  end

  def elapsed(current_thing,past_thing)
      current_thing - past_thing
  end

  def calculate_and_cache_attributes

    last_time = 0
    last_distance = 0
    last_altitude = 0

    track_points.each do |track_point|

      # Initialize 
      last_time=track_point.time if last_time == 0
      last_distance=track_point.distance if last_distance == 0
      last_altitude=track_point.altitude if last_altitude == 0

      # Joules
      @joules_c += track_point.watts*elapsed(track_point.time,last_time)
      
      # Ride Time
      if( elapsed(track_point.distance,last_distance) > 0 || track_point.cadence > 0 || track_point.watts > 0 )
        @ride_time_c += elapsed(track_point.time,last_time) 
      end

      # Elevation
      if last_altitude <= track_point.altitude
        @elevation_gain_c += (track_point.altitude - last_altitude)
      else
        @elevation_loss_c += (last_altitude - track_point.altitude)
      end 

      last_time=track_point.time
      last_distance=track_point.distance      
      last_altitude=track_point.altitude
    
    end 

  end
  
  end
end
