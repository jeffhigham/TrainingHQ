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

    if( found_in_cache? cache_key )
      logger.info("Found activity: #{self.id}!") 
      return send_from_cache cache_key
    else
      logger.info("Failed to find activity:#{self.id} in any cache store. Digging it from the database.\n")
      trackpoint_data = self.object_stores.where( name: "trackpoint_data").first.payload
    end

    if( !write_to_cache(cache_key, trackpoint_data))
      logger.warn("Attempt to add activity: #{self.id} to the cache failed! Returning database data.")
      return trackpoint_data
    else
      logger.info("Successfully added activity: #{self.id} to the cache!")
      cached_data = send_from_cache(cache_key)
    end

    cached_data
  
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