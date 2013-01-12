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

    def initialize
      @watts      = 0
      @cadence    = 0
    end
    
  end
end
