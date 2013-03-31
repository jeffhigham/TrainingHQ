module Guppy
  class Activity

    @@attributes = [  
                      :garmin_activity_id, :creator_name, :product_id,
                      :sport, :unit_id, :author_name, :activity_date,
                      
                      :max_heart_rate, :min_heart_rate, :avg_heart_rate,
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
    attr_accessor :laps

    def initialize
      @laps   = []
      zero_all_attrs
    end

    def zero_all_attrs
      @@attributes.each do |a|
        instance_variable_set "@#{a}", 0
      end
    end

    def to_hash
     @@attributes.each_with_object({}) { |a,h| 
        h[a] =  self.send("#{a}") 
      }
    end

    def find_max_min_avg_in_collection_of_obj(obj_collection,obj_attribute,max_min_avg)
      case max_min_avg
        when :max
          obj_collection.each.inject(0){|max,collection| max = collection.send(obj_attribute) > max ? collection.send(obj_attribute) : max; max  }
        when :min
          obj_collection.each.inject(0){|min,collection| min = collection.send(obj_attribute) < min ? collection.send(obj_attribute) : min; min  }
        when :avg
          obj_collection.each.inject(0){|sum,collection| sum + collection.send(obj_attribute) } / obj_collection.count 
      end
    end

    def find_sum_in_collection_of_obj(obj_collection,obj_attribute)
      obj_collection.inject(0) { |sum,collection| sum + collection.send(obj_attribute) }
    end

    def max_heart_rate
      find_max_min_avg_in_collection_of_obj(laps.each,:max_heart_rate,:max).round(0)
    end

    def min_heart_rate
      find_max_min_avg_in_collection_of_obj(laps.each,:min_heart_rate,:min).round(0)
    end

    def avg_heart_rate
      find_max_min_avg_in_collection_of_obj(laps.each,:avg_heart_rate,:avg).round(0)
    end

    def max_watts
      find_max_min_avg_in_collection_of_obj(laps.each,:max_watts,:max).round(0)
    end

    def min_watts
      find_max_min_avg_in_collection_of_obj(laps.each,:min_watts,:min).round(0)
    end

    def avg_watts
      find_max_min_avg_in_collection_of_obj(laps.each,:avg_watts,:avg).round(0)
    end

    def max_cadence
      find_max_min_avg_in_collection_of_obj(laps.each,:max_cadence,:max).round(0)
    end

    def min_cadence
      find_max_min_avg_in_collection_of_obj(laps.each,:min_cadence,:min).round(0)
    end

    def avg_cadence
      find_max_min_avg_in_collection_of_obj(laps.each,:avg_cadence,:avg).round(0)
    end

    def max_speed
      find_max_min_avg_in_collection_of_obj(laps.each,:max_speed,:max).round(2)
    end

    def min_speed
      find_max_min_avg_in_collection_of_obj(laps.each,:min_speed,:min).round(2)
    end

    def avg_speed
      find_max_min_avg_in_collection_of_obj(laps.each,:avg_speed,:avg).round(2)
    end

    def max_temp
      find_max_min_avg_in_collection_of_obj(laps.each,:max_temp,:max).round(0)
    end

    def min_temp
      find_max_min_avg_in_collection_of_obj(laps.each,:min_temp,:min).round(0)
    end

    def avg_temp
      find_max_min_avg_in_collection_of_obj(laps.each,:avg_temp,:avg).round(0)
    end

    def max_altitude
      find_max_min_avg_in_collection_of_obj(laps.each,:max_altitude,:max).round(2)
    end

    def min_altitude
      find_max_min_avg_in_collection_of_obj(laps.each,:min_altitude,:min).round(2)
    end

    def avg_altitude
      find_max_min_avg_in_collection_of_obj(laps.each,:avg_altitude,:avg).round(2)
    end

    def total_laps
      laps.count
    end

    def total_trackpoints
      find_sum_in_collection_of_obj(laps,:total_trackpoints)
    end

    def calories
      find_sum_in_collection_of_obj(laps,:calories)
    end

    def kjoules
      find_sum_in_collection_of_obj(laps,:kjoules).round(2)
    end

    def start_time
      laps.first.start_time
    end

    def ride_time
      find_sum_in_collection_of_obj(laps,:ride_time).round(0)
    end

    def total_time
      find_sum_in_collection_of_obj(laps,:total_time).round(0)
    end

    def distance
      find_sum_in_collection_of_obj(laps,:distance).round(2)
    end

    def elevation_gain
      find_sum_in_collection_of_obj(laps,:elevation_gain).round(2)
    end

    def elevation_loss
      find_sum_in_collection_of_obj(laps,:elevation_loss).round(2)
    end

    def intensity
      laps.first.intensity
    end

  end
end
