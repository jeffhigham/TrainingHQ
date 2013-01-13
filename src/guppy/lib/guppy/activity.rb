module Guppy
  class Activity
    attr_accessor :sport
    attr_accessor :activity_date
    attr_accessor :id
    attr_accessor :creator_name
    attr_accessor :product_id
    attr_accessor :unit_id
    attr_accessor :author_name
    attr_reader   :laps

    def initialize
      @laps          = []
      @sport         = "unknown"
      @activity_date = "unknown"
      @id            = "unknown"
      @creator_name  = "unknown"
      @product_id    = "unknown"
      @unit_id       = "unknown"
    end

    def distance
      laps.inject(0.0) { |sum, lap| sum + lap.distance }
    end
  end
end
