class Activity < ActiveRecord::Base

  attr_accessible :garmin_activity_id, :creator_name, :product_id, :sport, :unit_id, :datafile, 
                  :author_name, :activity_date, :name, :user_id, :processed, :status, 
                  :elevation_gain, :elevation_loss, :kjoules, :total_laps, :total_trackpoints, 
                  :ride_time, :distance, :max_watts, :min_watts, :avg_watts, :max_heart_rate,
                  :min_heart_rate, :avg_heart_rate, :max_cadence, :min_cadence, :avg_cadence,
                  :max_temp, :min_temp, :avg_temp, :max_speed, :min_speed, :avg_speed, :calories,
                  :max_altitude, :min_altitude, :avg_altitude, :start_time, :total_time, :intensity
                  
  has_attached_file :datafile
  has_many :laps, dependent: :destroy
  has_many :object_stores, dependent: :destroy
  belongs_to :user

  require "./lib/shared_methods.rb"
  include SharedMethods


  def elevation_loss_feet
    return distance_meters_to_feet(self.elevation_loss)
  end

  def elevation_gain_feet
    return distance_meters_to_feet(self.elevation_gain)
  end

  def min_altitude_feet
    return distance_meters_to_feet(self.min_altitude)
  end

  def max_altitude_feet
    return distance_meters_to_feet(self.max_altitude)
  end

  def total_time_formatted
    time_formatted(self.total_time.to_i)  # fix total_time data type!! string -> int
  end

  def ride_time_formatted
    time_formatted(self.ride_time)
  end

  def distance_miles
    distance_meters_to_miles(self.distance)
  end

  def distance_feet
    distance_meters_to_feet(self.distance)
  end

  def elevation_feet
    distance_meters_to_feet(self.elevation_gain)
  end

  def max_speed_mph
    (self.max_speed*2.2369).round(1)
  end

  def avg_speed_mph
    (self.avg_speed*2.2369).round(1)
  end

  def min_speed_mph
    (self.min_speed*2.2369).round(1)
  end

  def found_in_cache?(cache_key)
    cache_stores = {
    mem_cache_store:  ActiveSupport::Cache.lookup_store(:mem_cache_store),
    #memory_store:  ActiveSupport::Cache.lookup_store(:memory_store),
    file_store:  ActiveSupport::Cache.lookup_store(:file_store, "/tmp/ramdisk/cache")
    }

    cache_stores.each_pair do |k,v|
      if( v.exist? cache_key)
        logger.info("Found #{cache_key} in #{k}.")
        return true
      end
    end
    return false
  end

  def send_from_cache(cache_key)
    cache_stores = {
    mem_cache_store:  ActiveSupport::Cache.lookup_store(:mem_cache_store),
    #memory_store:  ActiveSupport::Cache.lookup_store(:memory_store),
    file_store:  ActiveSupport::Cache.lookup_store(:file_store, "/tmp/ramdisk/cache")
    }
    cache_stores.each_pair do |k,v|
      if( v.exist? cache_key)
        logger.info("Sending #{cache_key} in from #{k}.")
        return v.read(cache_key)
      end
    end
    return false
  end

  def write_to_cache(cache_key, data)
    cache_stores = {
    mem_cache_store:  ActiveSupport::Cache.lookup_store(:mem_cache_store),
    #memory_store:  ActiveSupport::Cache.lookup_store(:memory_store),
    file_store:  ActiveSupport::Cache.lookup_store(:file_store, "/tmp/ramdisk/cache")
    }
    cache_stores.each_pair do |k,v|
      if( v.write(cache_key, data ) )
        logger.info("Added #{cache_key} to #{k}.")
        return true
      end
    end
    return false
  end

  def get_trackpoint_data
    logger.info("Controller called activity.get_trackpoint_data!")

    cache_key = "#{self.id}_trackpoints"
    #if ( self.object_stores.count == 0 )
    #cached_data = Rails.cache.read(cache_key)

    if( found_in_cache? cache_key )

      logger.info("Found activity: #{self.id}!") 
      return send_from_cache cache_key
    
    else

      logger.info("Failed to find activity:#{self.id} in any cache store. Digging it from the database.\n")

      trackpoint_data = []
      last_trackpoint_distance = 0
      last_trackpoint_altitude = 0
      percent_grade = 0
      trackpoint_percent_grade_rollover = 20 # number of samples to avg for %grade
      trackpoint_percent_grade_values = [0,0] # holds trackpoint_percent_grade_rollover values
      trackpoint_avg_percent_grade = 0 # average %grade based on trackpoint_percent_grade_rollover
      trackpoint_current_time = 0 # trackpoint time in unix time (seconds)

      self.laps.each_with_index do |lap, lap_index|

        trackpoint_data[lap_index] = []

        lap.trackpoints.each_with_index do |trackpoint,trackpoint_index|

            # find percent grade if we actually traveled any distance. Otherwise it will remain 0 or last average calculation.
            if ( trackpoint.distance_feet - last_trackpoint_distance) > 0
              percent_grade = ( (trackpoint.altitude_feet - last_trackpoint_altitude) / (trackpoint.distance_feet - last_trackpoint_distance) )*100
            end

            # average out %grade values based on trackpoint_percent_grade_rollover
            trackpoint_avg_percent_grade = (trackpoint_percent_grade_values.inject{ |sum, el| sum + el }/trackpoint_percent_grade_values.count).round 
            # remove the oldest value if we have reached trackpoint_percent_grade_rollover
            trackpoint_percent_grade_values.shift if ( trackpoint_percent_grade_values.count == trackpoint_percent_grade_rollover )
            # add a new value to the array
            trackpoint_percent_grade_values << percent_grade
          
          trackpoint_data [lap_index]<< {
            time_seconds_epoch: Time.parse(trackpoint.time).to_time.to_i,
            distance_feet: trackpoint.distance_feet.round,
            watts: trackpoint.watts, 
            heart_rate: trackpoint.heart_rate, 
            cadence: trackpoint.cadence,
            altitude_feet: trackpoint.altitude_feet.round,
            speed_mph: trackpoint.speed_mph,
            lng: trackpoint.longitude, 
            lat: trackpoint.latitude,
            percent_grade: trackpoint_avg_percent_grade,
            temp_c: 0
          }

          last_trackpoint_distance = trackpoint.distance_feet
          last_trackpoint_altitude = trackpoint.altitude_feet

        end

      end

     #self.object_stores.create( name: "trackpoint_data", payload: trackpoint_data)
      if( !write_to_cache(cache_key, trackpoint_data))
        logger.warn("Attempt to add activity: #{self.id} to the cache failed! Returning database data.")
       # return trackpoint_data
      else
        logger.info("Successfully added activity: #{self.id} to the cache!")
        cached_data = send_from_cache(cache_key)
      end
    end
    cached_data
    #self.object_stores.where( name: "trackpoint_data").first.payload
  end


  def map_data
    json = []
    points = []
      self.laps.each do |lap|
      lap.trackpoints.each do |trackpoint|
        unless  trackpoint.longitude === 0 or trackpoint.latitude === 0
          points  << { lng: trackpoint.longitude,lat: trackpoint.latitude }
        end
      end
    end
    json << points
    return json.to_json
  end

end