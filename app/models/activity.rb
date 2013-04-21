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
    speed_kmph_to_mph(self.max_speed)
  end

  def avg_speed_mph
    speed_kmph_to_mph(self.avg_speed)
  end

  def javascript_data

    if ( self.object_stores.count == 0 )

      lap_start_distances = []
      lap_start_times = []
      data_distance = []
      data_time = []
      last_trackpoint_distance = 0
      last_trackpoint_altitude = 0
      time_offset = 0
      percent_grade = 0

      self.laps.each_with_index do |lap, lap_index|

        lap.trackpoints.each_with_index do |trackpoint,trackpoint_index|

          if ( lap_index == 0 and trackpoint_index == 0 ) 
            time_offset = Time.parse(trackpoint.time).to_time.to_i
          end

          if ( trackpoint_index == 0)
            lap_start_distances << trackpoint.distance_feet
            lap_start_times << Time.parse(trackpoint.time).to_time.to_i - time_offset
            percent_grade = 0;
          else
            percent_grade = ( (trackpoint.altitude_feet - last_trackpoint_altitude) / (trackpoint.distance_feet - last_trackpoint_distance) )*100
          end

          #logger.info "percent_grade = ( (#{trackpoint.altitude_feet} - #{last_trackpoint_altitude}) / (#{trackpoint.distance_feet} - #{last_trackpoint_distance}) )*100\n"
          #logger.info "percent_grade = #{percent_grade}\n\n"



          data_time << [ Time.parse(trackpoint.time).to_time.to_i - time_offset, trackpoint.watts, trackpoint.heart_rate, 
                            trackpoint.cadence, trackpoint.altitude_feet, trackpoint.speed.to_f, trackpoint.longitude, trackpoint.latitude, percent_grade  ];

          if (trackpoint.distance_feet - last_trackpoint_distance) > 0
            
            #last_trackpoint_distance = trackpoint.distance_feet
            #last_trackpoint_altitude = trackpoint.altitude_feet
            data_distance << [ trackpoint.distance_feet , trackpoint.watts, trackpoint.heart_rate, 
                            trackpoint.cadence, trackpoint.altitude_feet, trackpoint.speed.to_f, trackpoint.longitude, 
                            trackpoint.latitude, percent_grade ] unless trackpoint.distance_miles == 0
          end
          last_trackpoint_distance = trackpoint.distance_feet
          last_trackpoint_altitude = trackpoint.altitude_feet

        end

      end

      self.object_stores.create( name: "data_distance", payload: data_distance)
      self.object_stores.create( name: "data_time", payload: data_time)
      self.object_stores.create( name: "lap_start_times", payload: lap_start_times)
      self.object_stores.create( name: "lap_start_distances", payload: lap_start_distances)

    end

    {
      data_distance: self.object_stores.where(name: "data_distance").first.payload,
      data_time: self.object_stores.where(name: "data_time").first.payload,
      lap_start_distances: self.object_stores.where(name: "lap_start_distances").first.payload,
      lap_start_times: self.object_stores.where(name: "lap_start_times").first.payload
    }

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