module Guppy
  class TrackPoint

    attr_accessor :altitude
    attr_accessor :cadence
    attr_accessor :distance
    attr_accessor :heart_rate
    attr_accessor :latitude
    attr_accessor :longitude
    attr_accessor :time
    attr_accessor :watts
    attr_accessor :speed
    attr_accessor :joules

    @@attributes = [ :altitude, :cadence, :distance, :heart_rate,
                     :latitude, :longitude, :time, :watts,
                     :speed, :joules ]

    attr_accessor *@@attributes

    def initialize
      zero_all_attrs
    end

    def zero_all_attrs
      @@attributes.each do |a|
        instance_variable_set "@#{a}", 0
      end
    end

    def distance_feet
    return (self.distance * 3.281).round(1) 
    end

    def altitude_feet
      return (self.altitude * 3.281).round(1)
    end

    def distance_miles # self.distance is in meters.
      (self.distance/1609.34).to_f.round(1)
    end

    def speed_mph
      (self.speed*2.2369).round(1)
    end

    def to_hash
     @@attributes.each_with_object({}) { 
        |a,h| h[a] = instance_variable_get "@#{a}" 
      }
    end
    
  end
end