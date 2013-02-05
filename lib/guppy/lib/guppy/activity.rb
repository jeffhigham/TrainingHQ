module Guppy
  class Activity
    attr_accessor :id
    attr_accessor :creator_name
    attr_accessor :product_id
    attr_accessor :sport
    attr_accessor :unit_id
    attr_accessor :author_name
    attr_accessor :activity_date
    #attr_accessor :elevation_gain
    #attr_accessor :elevation_loss
    attr_accessor :laps

    def initialize
      @laps   = []
    end

   def total_laps
      laps.count
   end

   def total_trackpoints
     laps.inject(0.0) { |sum,lap| sum + lap.track_points.count } 
   end

  def kjoules
    laps.inject(0.0) { |sum,lap| sum + lap.kjoules}
  end

  def ride_time
    laps.inject(0.0) { |sum,lap| sum + lap.ride_time}
  end

  def total_time
    laps.inject(0.0) { |sum,lap| sum + lap.total_time }
  end

  def distance
    laps.inject(0.0) { |sum,lap| sum + lap.distance }
  end

  def elevation_gain
    laps.inject(0.0) { |sum,lap| sum + lap.elevation_gain }
  end

  def elevation_loss
    laps.inject(0.0) { |sum,lap| sum + lap.elevation_loss }
  end

  end
end
