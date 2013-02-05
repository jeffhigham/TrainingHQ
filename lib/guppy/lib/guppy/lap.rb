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
    attr_accessor :elevation_gain
    attr_accessor :elevation_loss
    attr_accessor :joules
    attr_accessor :lap_ride_time
    attr_accessor :track_points
    
    def initialize
      @track_points = []
      @joules = 0
      @lap_ride_time = 0
    end

  def total_trackpoints
      track_points.count
  end

  def kjoules
    load_joules if @joules == 0
    @joules/1000
  end

  def load_joules
    last_time = 0
    track_points.each do |track_point|
      if(last_time==0)
        last_time=track_point.time
      else
        track_point.joules = track_point.watts*elapsed(track_point.time,last_time)
        @joules += track_point.joules
        last_time=track_point.time
      end
    end

  end

  def ride_time
    load_ride_time if @lap_ride_time == 0
    @lap_ride_time
  end

  def load_ride_time
    last_time = 0
    last_distance = 0
    
    track_points.each do |track_point|
    
      if(last_time==0 || last_distance == 0)
        last_time=track_point.time
        last_distance=track_point.distance
      else
        # only increment time if we change distance, move a pedal, or generate a watt.
        if( elapsed(track_point.distance,last_distance) > 0 || track_point.cadence > 0 || track_point.watts > 0 )
          @lap_ride_time += elapsed(track_point.time,last_time) 
        end
        last_time=track_point.time
        last_distance=track_point.distance
      end
    end

  end

  def elapsed(current_thing,past_thing)
      current_thing - past_thing
  end

  end
end
