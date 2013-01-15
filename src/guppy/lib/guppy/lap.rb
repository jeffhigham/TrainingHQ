module Guppy
  class Lap
    attr_accessor :distance
    attr_accessor :ave_speed
    attr_accessor :max_speed
    attr_accessor :time
    attr_accessor :calories
    attr_accessor :ave_heart_rate
    attr_accessor :max_heart_rate
    attr_accessor :ave_watts
    attr_accessor :max_watts
    attr_accessor :ave_cadence
    attr_accessor :max_cadence
    attr_accessor :intensity
    attr_reader   :track_points
    
    def initialize
      @distance           = 0.0
      @max_speed          = 0.0
      @ave_speed          = 0.0
      @time               = 0.0
      @calories           = 0
      @ave_heart_rate     = 0
      @max_heart_rate     = 0
      @ave_watts          = 0
      @max_watts          = 0
      @ave_cadence        = 0
      @max_cadence        = 0
      @intensity          = "unknown"
      @track_points       = []
    end

  end
end
