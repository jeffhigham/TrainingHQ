module Guppy
  class Activity
    
    attr_accessor :garmin_activity_id
    attr_accessor :creator_name
    attr_accessor :product_id
    attr_accessor :sport
    attr_accessor :unit_id
    attr_accessor :author_name
    attr_accessor :activity_date
    attr_accessor :laps

    @@attributes = [  

                      #:max_heart_rate,
                      #:min_heart_rate,
                      #:avg_heart_rate,

                      #:max_watts,
                      #:min_watts,
                      #:avg_watts,

                      #:max_cadence, 
                      #:min_cadence, 
                      #:avg_cadence,

                      #:max_speed,
                      #:min_speed,
                      #:avg_speed,

                      :max_temp,
                      :min_temp,
                      :avg_temp,

                      :max_altitude,
                      :min_altitude,
                      :avg_altitude,

                      :start_time,
                      #:total_time,
                      #:ride_time,

                      :calories,
                      #:distance,
                      :intensity,
                      
                      #:elevation_gain,
                      #:elevation_loss,
                      #:kjoules,
                      #:total_trackpoints

                    ]

    attr_accessor *@@attributes

    def initialize
      @laps   = []
      zero_all_attrs
    end

    def zero_all_attrs
      @@attributes.each do |a|
        instance_variable_set "@#{a}", 0
      end
    end

  def max_heart_rate
    find_max_min_avg_in_collection_of_obj(laps.each,:max_heart_rate,:max)
  end

  def min_heart_rate
    find_max_min_avg_in_collection_of_obj(laps.each,:min_heart_rate,:min)
  end

  def avg_heart_rate
    find_max_min_avg_in_collection_of_obj(laps.each,:avg_heart_rate,:avg)
  end

  def max_watts
    find_max_min_avg_in_collection_of_obj(laps.each,:max_watts,:max)
  end

  def min_watts
    find_max_min_avg_in_collection_of_obj(laps.each,:min_watts,:min)
  end

  def avg_watts
    find_max_min_avg_in_collection_of_obj(laps.each,:avg_watts,:avg)
  end

  def max_cadence
    find_max_min_avg_in_collection_of_obj(laps.each,:max_cadence,:max)
  end

  def min_cadence
    find_max_min_avg_in_collection_of_obj(laps.each,:min_cadence,:min)
  end

  def avg_cadence
    find_max_min_avg_in_collection_of_obj(laps.each,:avg_cadence,:avg)
  end

  def max_speed
    find_max_min_avg_in_collection_of_obj(laps.each,:max_speed,:max)
  end

  def min_speed
    find_max_min_avg_in_collection_of_obj(laps.each,:min_speed,:min)
  end

  def avg_speed
    find_max_min_avg_in_collection_of_obj(laps.each,:avg_speed,:avg)
  end

  def max_temp
    find_max_min_avg_in_collection_of_obj(laps.each,:max_temp,:max)
  end

  def min_temp
    find_max_min_avg_in_collection_of_obj(laps.each,:min_temp,:min)
  end

  def avg_temp
    find_max_min_avg_in_collection_of_obj(laps.each,:avg_temp,:avg)
  end

  def find_max_min_avg_in_collection_of_obj(obj_collection,obj_attribute,max_min_avg)
    case max_min_avg
      when :max
        obj_collection.each.inject(0){|max,collection| max = collection.send(obj_attribute) > max ? collection.send(obj_attribute) : max; max  }
      when :min
        obj_collection.each.inject(0){|min,collection| min = collection.send(obj_attribute) < min ? collection.send(obj_attribute) : min; min  }
      when :avg
        obj_collection.each.inject(0){|sum,collection| sum += collection.send(obj_attribute); sum } / obj_collection.count 
    end
  end

  def total_laps
    laps.count
  end

  def total_trackpoints
    laps.inject(0.0) { |sum,lap| sum + lap.track_points.count } 
  end

  def calories
    laps.inject(0) { |sum,lap| sum + lap.calories }
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

  def to_hash
      {
        garmin_activity_id: garmin_activity_id,
        creator_name: creator_name,
        product_id: product_id,
        sport: sport,
        unit_id: unit_id,
        author_name: author_name,
        activity_date: activity_date,
        total_laps: total_laps,
        kjoules: kjoules,
        ride_time: ride_time,
        total_trackpoints: total_time,
        distance: distance,
        elevation_gain: elevation_gain,
        elevation_loss: elevation_loss
      }
  end

  end
end
