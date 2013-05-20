module THQ
  
  class Compressor

    @@attributes = [ :activity_obj, :trackpoint_max]
    attr_accessor *@@attributes

    def self.open(activity_obj,trackpoint_max)
      compressor = self.new(activity_obj,trackpoint_max)
      compressor.compress
    end

    def initialize(activity_obj,trackpoint_max)
      @activity_obj = activity_obj
      @trackpoint_max = trackpoint_max
    end

    def compress

          puts "Entering THQ::compressor..."
          trackpoint_data = []
          trackpoint_lap_data = []
          wattage_data = []
          percentage = 0  # percentage of trackpoints to scale.
          scale_now = 0 # number of trackpoints to loop through before adding to scaled_dataset.
          max_values = { watts: 0, heart_rate: 0, cadence: 0, altitude_feet: 0, speed_mph: 0, percent_grade: 0}
          loop_count = 0  # trackpoint loop counter.

          device_activity = @activity_obj.activities.first
          puts "\tLocated activity #{device_activity.garmin_activity_id}"

          # Grab the percentage @trackpoint_max is of all trackpoints.
          percentage = (device_activity.total_trackpoints > @trackpoint_max) ? (@trackpoint_max/device_activity.total_trackpoints.to_f) * 100 : 100
          percentage = 1 if percentage == 0 # sometimes we have a large dataset that scales uner 1%
          puts "\tBest fit setting for #{device_activity.garmin_activity_id} is #{percentage}% maximum #{@trackpoint_max} trackpoints"
          scale_now = (device_activity.total_trackpoints / (device_activity.total_trackpoints*(percentage/100.to_f)) ).round(2)
          puts "\tScaling #{device_activity.total_trackpoints} values, capturing every #{scale_now}th dataset."

          # Process and store each lap in the database;
          device_activity.laps.each_with_index do |device_lap, lap_index|
              puts "\t\tLocated lap in #{device_activity.garmin_activity_id} with #{device_lap.total_trackpoints} trackpoints.\n"

              # Process every trackpoint.
              puts "\t\tNow processing #{device_lap.total_trackpoints} trackpoints..."
              trackpoint_lap_data[lap_index] = []
              wattage_data[lap_index] = []

              device_lap.track_points.each_with_index do |trackpoint,trackpoint_index|

                # Promote the max values for watts, hr, cadence, and speed when we scale down.
                max_values[:time_seconds_epoch] = trackpoint.time.to_time.to_i
                max_values[:distance_feet] = trackpoint.distance_feet.round
                max_values[:watts] = trackpoint.watts > max_values[:watts] ? trackpoint.watts : max_values[:watts]
                max_values[:heart_rate] = trackpoint.heart_rate > max_values[:heart_rate] ? trackpoint.heart_rate : max_values[:heart_rate]
                max_values[:cadence] = trackpoint.cadence > max_values[:cadence] ? trackpoint.cadence : max_values[:cadence]
                max_values[:altitude_feet] = trackpoint.altitude_feet.round
                max_values[:speed_mph] = trackpoint.speed_mph > max_values[:speed_mph] ? trackpoint.speed_mph : max_values[:speed_mph]
                max_values[:lng] = trackpoint.longitude
                max_values[:lat] = trackpoint.latitude
                max_values[:percent_grade] = trackpoint.percent_grade > max_values[:percent_grade] ? trackpoint.percent_grade : max_values[:percent_grade]

                # It is possible for scale_now to be < 1 for higher scale_factors.
                # so let's capture that here.
                loop_count += (scale_now < 1) ? scale_now : 1;

                if scale_now < 1 
                  if loop_count >= 1 
                    trackpoint_data << {
                      time_seconds_epoch: max_values[:time_seconds_epoch],
                      distance_feet: max_values[:distance_feet],
                      watts: max_values[:watts], 
                      heart_rate: max_values[:heart_rate], 
                      cadence: max_values[:cadence],
                      altitude_feet: max_values[:altitude_feet],
                      speed_mph: max_values[:speed_mph],
                      lng: max_values[:lng],
                      lat: max_values[:lat],
                      percent_grade: max_values[:percent_grade],
                      temp_c: 0
                      }
                    loop_count=0
                    max_values = { watts: 0, heart_rate: 0, cadence: 0, altitude_feet: 0, speed_mph: 0, percent_grade: 0}
                  end
                elsif loop_count == scale_now.round()  # time to record a value.
                  trackpoint_data << {
                      time_seconds_epoch: max_values[:time_seconds_epoch],
                      distance_feet: max_values[:distance_feet],
                      watts: max_values[:watts], 
                      heart_rate: max_values[:heart_rate], 
                      cadence: max_values[:cadence],
                      altitude_feet: max_values[:altitude_feet],
                      speed_mph: max_values[:speed_mph],
                      lng: max_values[:lng],
                      lat: max_values[:lat],
                      percent_grade: max_values[:percent_grade],
                      temp_c: 0
                      }
                  loop_count=0
                  max_values = { watts: 0, heart_rate: 0, cadence: 0, altitude_feet: 0, speed_mph: 0, percent_grade: 0}
                end

                trackpoint_lap_data[lap_index] << {
                  time_seconds_epoch: trackpoint.time.to_time.to_i,
                  distance_feet: trackpoint.distance_feet.round,
                  watts: trackpoint.watts, 
                  heart_rate: trackpoint.heart_rate, 
                  cadence: trackpoint.cadence,
                  altitude_feet: trackpoint.altitude_feet.round,
                  speed_mph: trackpoint.speed_mph,
                  lng: trackpoint.longitude,
                  lat: trackpoint.latitude,
                  percent_grade: trackpoint.percent_grade,
                  temp_c: 0
                }

                # data needed to calculate NP,FTP,ETC
                wattage_data[lap_index] << {
                  time_seconds_epoch: trackpoint.time.to_time.to_i,
                  watts: trackpoint.watts
                }

                last_trackpoint_distance = trackpoint.distance_feet
                last_trackpoint_altitude = trackpoint.altitude_feet

              end
             
          end 
          puts "Leaving THQ::compressor..."

          return {
            trackpoint_data: trackpoint_data,
            trackpoint_lap_data: trackpoint_lap_data,
            wattage_data: wattage_data
          }
    end # compress

  end # Compressor

end # THQ