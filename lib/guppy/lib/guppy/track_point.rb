module Guppy
  class TrackPoint
    attr_accessor :latitude
    attr_accessor :longitude
    attr_accessor :altitude
    attr_accessor :heart_rate
    attr_accessor :distance
    attr_accessor :time
    attr_accessor :cadence
    attr_accessor :watts
    attr_accessor :speed

    def initialize
      @latitude   = 0
      @longitude  = 0
      @altitude   = 0
      @heart_rate = 0
      @distance   = 0
      @time       = 0
      @cadence    = 0
      @watts      = 0
      @speed      = 0
    end
    
  end
end