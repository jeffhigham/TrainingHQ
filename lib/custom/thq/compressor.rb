module THQ
  
  class Compressor

    ################################################################################
    # The purpose of the Compressor is to take a large datafile and scale it down 
    # to increase performance on the front-end for the interactive graph. Most
    # users will not need to see *every* single datapoint on the graph as there
    # can be 10s of 1000s of them in the JSON.  Here we attempt to keep the total 
    # down to about 3000 for the activity as a whole and for each lap while at
    # the same time, attempt to preserve the maximum values for watts, speed,
    # heart rate, cadence, altitude, etc.  Otherwise, a straight average would
    # simply flatten out the graph and misrepresent the data.  3000 seems to be a
    # good compromise showing enough detail and limiting performace lags in the
    # browser. 3k also fits into a 1m memcached segment.
    #
    # Wattage and trackpoint data are not scaled down so we preserve raw data
    # for calculating TSS, NP, IF and so the map is as accurate as possible.
    #
    # Blanket disclaimer: This code is a bit of a hack, just like the author.
    ################################################################################

    require "benchmark"
    @@attributes = [ 
            :activity_obj, # Parsed XML Document.
            :trackpoint_max, # Max values to return in the scaled dataset.
            :compressed, # Hash we return after compressing activity_obj to trackpoit_max values.
            :debug
          ]
    attr_accessor *@@attributes

    def self.open(activity_obj,trackpoint_max)
      puts "Entering THQ::Compressor..."
      compressor = nil
      time = Benchmark.realtime do
        compressor = self.new(activity_obj,trackpoint_max)
      end
      puts "New compressor obj create. Time: #{(time*1000).round(4)}ms (#{time.round(1)}s)."
      time = Benchmark.realtime do
       @compressed = compressor.compress
      end
      puts "Leaving THQ::Compressor Time: #{(time*1000).round(4)}ms (#{time.round(1)}s)."
      @compressed
    end

    def initialize(activity_obj,trackpoint_max)
      @activity_obj = activity_obj
      @trackpoint_max = trackpoint_max
      @debug = true
    end

    def calculate_scale(total,max)
      percentage = (total> max) ? ((max/total.to_f) * 100).round() : 100
      percentage = 1 if percentage == 0 
      #scale_now = (total / (total*(percentage/100.to_f)) ).round(2)
      scale_now = (total/ (total*(percentage/100.to_f)) ).round()
      scale_now = 1 if scale_now == 0 # minimum time we can push a trackpoint is every loop.
      puts "\t**THQ:Compressor.calculate_scale.Total Values: #{total}, Scale Now: #{scale_now}, Percentage: #{percentage}." if @debug
      scale_now
    end

    def compress

          ###########################################################################################
          trackpoint_data = []  # Compressed activity as a whole we will return.
          trackpoint_lap_data = [] # Compressed data per lap.
          wattage_lap_data = [] # Uncompressed wattage (time / watts) data by lap index.
          percentage = 0  # Percentage of trackpoints to scale.
          push_to_scaled_dataset_now = 0 # Number of trackpoints to loop through before adding to scaled_dataset.
          
          # Hash for max values scaled for the whole activity. 
          max_values = { watts: 0, heart_rate: 0, cadence: 0, 
                        altitude_feet: 0, speed_mph: 0, percent_grade: 0}

          loop_count = 0  # Activity-specific loop counter.
          device_activity = nil 
          ###########################################################################################

          puts "\tLoading activities..." if @debug
          time = Benchmark.realtime do
            #device_activity = @activity_obj.activities.first  # assuming only 1 activity in each datafile.
            device_activity = @activity_obj.activities
          end
          puts "\tLocated activity #{device_activity.garmin_activity_id} Time: #{(time*1000).round(4)}ms (#{time.round(1)}s)." if @debug

          push_to_scaled_dataset_now = calculate_scale(device_activity.total_trackpoints, @trackpoint_max)
          puts "\tActivity: Scaling #{device_activity.total_trackpoints} trackpoints, capturing every #{push_to_scaled_dataset_now} trackpoint." if @debug

          puts "\tLocating laps..." if @debug
          # LAP: Loop through the laps in device_activity
          device_activity.laps.each_with_index do |device_lap, lap_index|
              puts "\t\tLocated lap in #{device_activity.garmin_activity_id} with #{device_lap.total_trackpoints} trackpoints.\n" if @debug

              # Set a lap_index for each dataset broken down by lap.
              trackpoint_lap_data[lap_index] = []
              wattage_lap_data[lap_index] = []
              # Hash for max values scaled per lap.
              max_lap_values = { watts: 0, heart_rate: 0, cadence: 0, altitude_feet: 0, speed_mph: 0, percent_grade: 0}
              lap_loop_count = 0 # Lap-specific trackpoint loop counter.

              # Set a lap-specific percentag and push_to_scaled_dataset_now value here.
              push_to_lap_scaled_dataset_now = calculate_scale(device_lap.total_trackpoints, @trackpoint_max)
              puts "\t\tLap: Scaling #{device_lap.total_trackpoints} trackpoints, capturing every #{push_to_lap_scaled_dataset_now} trackpoint." if @debug

              # TRACKPOINT: Loop through the track_points in device_lap.
              device_lap.track_points.each_with_index do |trackpoint,trackpoint_index|

                # Promote the max values for watts, hr, cadence, and speed when we scale down.
                max_values[:time_seconds_epoch] = trackpoint.time.to_time.to_i
                max_values[:distance_feet] = trackpoint.distance_feet.round
                max_values[:watts] = trackpoint.watts if (trackpoint.watts > max_values[:watts])
                max_values[:heart_rate] = trackpoint.heart_rate if (trackpoint.heart_rate > max_values[:heart_rate])
                max_values[:cadence] =  trackpoint.cadence if (trackpoint.cadence > max_values[:cadence])
                max_values[:altitude_feet] = trackpoint.altitude_feet.round
                max_values[:speed_mph] = trackpoint.speed_mph if (trackpoint.speed_mph > max_values[:speed_mph])
                max_values[:lng] = trackpoint.longitude
                max_values[:lat] = trackpoint.latitude
                max_values[:percent_grade] = trackpoint.percent_grade
                loop_count += 1

                # Promote the max values as above but for each lap.
                max_lap_values[:time_seconds_epoch] = trackpoint.time.to_time.to_i
                max_lap_values[:distance_feet] = trackpoint.distance_feet.round
                max_lap_values[:watts] = trackpoint.watts if (trackpoint.watts > max_lap_values[:watts])
                max_lap_values[:heart_rate] = trackpoint.heart_rate if (trackpoint.heart_rate > max_lap_values[:heart_rate])
                max_lap_values[:cadence] = trackpoint.cadence if (trackpoint.cadence > max_lap_values[:cadence])
                max_lap_values[:altitude_feet] = trackpoint.altitude_feet.round
                max_lap_values[:speed_mph] = trackpoint.speed_mph if (trackpoint.speed_mph > max_lap_values[:speed_mph])
                max_lap_values[:lng] = trackpoint.longitude
                max_lap_values[:lat] = trackpoint.latitude
                max_lap_values[:percent_grade] = trackpoint.percent_grade
                lap_loop_count += 1

                if (loop_count == push_to_scaled_dataset_now)  # time to record a value.
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

                if (lap_loop_count == push_to_lap_scaled_dataset_now)  # time to record a value.
                  trackpoint_lap_data[lap_index] << {
                    time_seconds_epoch: max_lap_values[:time_seconds_epoch],
                    distance_feet: max_lap_values[:distance_feet],
                    watts: max_lap_values[:watts], 
                    heart_rate: max_lap_values[:heart_rate], 
                    cadence: max_lap_values[:cadence],
                    altitude_feet: max_lap_values[:altitude_feet],
                    speed_mph: max_lap_values[:speed_mph],
                    lng: max_lap_values[:lng],
                    lat: max_lap_values[:lat],
                    percent_grade: max_lap_values[:percent_grade],
                    temp_c: 0
                  }
                  lap_loop_count=0
                  max_lap_values = { watts: 0, heart_rate: 0, cadence: 0, altitude_feet: 0, speed_mph: 0, percent_grade: 0}
                end

                # data needed to calculate NP,FTP,ETC
                wattage_lap_data[lap_index] << {
                  time_seconds_epoch: trackpoint.time.to_time.to_i,
                  watts: trackpoint.watts
                }

                last_trackpoint_distance = trackpoint.distance_feet
                last_trackpoint_altitude = trackpoint.altitude_feet

              end
             
          end 

          return {
            trackpoint_data: trackpoint_data, # Activity as a whole.
            trackpoint_lap_data: trackpoint_lap_data, # Data with lap index.
            wattage_lap_data: wattage_lap_data # Wattage data with lap index.
          }
    end # compress

  end # Compressor

end # THQ