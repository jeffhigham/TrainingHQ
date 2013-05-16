
namespace :THQ do

  # Loads datafiles into the databae and cache. Currently messy / experimental code and needs
  # to be re-written properly.
  desc "Load unprocessed TCX files for all users, update activity, lap, and trackpoint data."
    task :load_new_activities => :environment do

        require './lib/guppy/lib/guppy.rb'
        
        file_store = ActiveSupport::Cache.lookup_store(:file_store, "/tmp/ramdisk/cache")
        mem_cache_store = ActiveSupport::Cache.lookup_store(:mem_cache_store)
        db_activities = Activity.where(:processed => 0)
        
        if db_activities.count > 0
          puts "There are #{db_activities.count} activities in the queue.\n"
          # Process and store activity summary in the database.          
          db_activities.each do |db_activity|

              trackpoint_data = []
              trackpoint_lap_data = []
              wattage_data = []
              last_trackpoint_distance = 0
              last_trackpoint_altitude = 0
              percent_grade = 0
              trackpoint_percent_grade_rollover = 20 # number of samples to avg for %grade
              trackpoint_percent_grade_values = [0,0] # holds trackpoint_percent_grade_rollover values
              trackpoint_avg_percent_grade = 0 # average %grade based on trackpoint_percent_grade_rollover
              trackpoint_current_time = 0 # trackpoint time in unix time (seconds)
              percentage = 0  # percentage of trackpoints to scale.
              scale_now = 0 # number of trackpoints to loop through before adding to scaled_dataset.
              trackpoint_max = 3000  # Max number of trackpoints on the database for map display.
              max_values = { watts: 0, heart_rate: 0, cadence: 0, altitude_feet: 0, speed_mph: 0}
              loop_count = 0  # trackpoint loop counter.


              puts "Crunching datafile for activity named \"#{db_activity.name}\"\n"
              device_activity = Guppy::DB.open(db_activity.datafile.path).activities.first # assuming only 1 per garmin file.
              puts "Located activity #{device_activity.garmin_activity_id} in \"#{db_activity.name}\"\n"
              db_activity.update_attributes(device_activity.to_hash)

              # Grab the percentage trackpoint_max is of all trackpoints.
              percentage = (db_activity.total_trackpoints > trackpoint_max) ? (trackpoint_max/db_activity.total_trackpoints.to_f) * 100 : 100
              percentage = 1 if percentage == 0 # sometimes we have a large dataset that scales uner 1%
              puts "Best fit setting for #{device_activity.garmin_activity_id} is #{percentage}%"
              #puts "debug:(#{db_activity.total_trackpoints} / (#{db_activity.total_trackpoints}*(#{percentage}/100)) ) "
              scale_now = (db_activity.total_trackpoints / (db_activity.total_trackpoints*(percentage/100.to_f)) ).round(2)
              puts "Scaling #{db_activity.total_trackpoints} values, capturing every #{scale_now}th dataset."

              # Process and store each lap in the database;
              device_activity.laps.each_with_index do |device_lap, lap_index|
                  puts "\tLocated lap in #{device_activity.garmin_activity_id} with #{device_lap.total_trackpoints} trackpoints.\n"
                  db_lap = db_activity.laps.create(device_lap.to_hash)


                  # Process every trackpoint.
                  puts "\tNow processing #{device_lap.total_trackpoints} trackpoints..."
                  trackpoint_lap_data[lap_index] = []
                  wattage_data[lap_index] = []

                  device_lap.track_points.each_with_index do |trackpoint,trackpoint_index|
                  
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
                    max_values[:percent_grade] = trackpoint_avg_percent_grade

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
                        max_values = { watts: 0, heart_rate: 0, cadence: 0, altitude_feet: 0, speed_mph: 0}
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
                      max_values = { watts: 0, heart_rate: 0, cadence: 0, altitude_feet: 0, speed_mph: 0}
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
                      percent_grade: trackpoint_avg_percent_grade,
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
                  
                  puts "done.\n"

              end
              scaled_cache_key = "#{db_activity.id}_scaled"
              puts "Added #{trackpoint_data.count} values as #{scaled_cache_key} to the mem_cache_store cache." if 
              mem_cache_store.write(scaled_cache_key, trackpoint_data)
              puts "Added #{trackpoint_data.count} values as #{scaled_cache_key} to the file_store cache." if 
              file_store.write(scaled_cache_key, trackpoint_data)
              puts

              trackpoint_lap_data.each_with_index do |lap_data,lap_index|

                cache_key = "#{db_activity.id}_lap_#{lap_index}"

                puts "Added #{cache_key} to the mem_cache_store cache." if 
                mem_cache_store.write(cache_key, trackpoint_lap_data[lap_index])
                puts "Added #{cache_key} to the file_store cache." if 
                file_store.write(cache_key, trackpoint_lap_data[lap_index])
                puts

                puts "Added #{cache_key}_wattage to the mem_cache_store cache." if
                mem_cache_store.write("#{cache_key}_wattage", trackpoint_lap_data[lap_index])
                puts "Added #{cache_key}_wattage to the file_store cache." if
                file_store.write("#{cache_key}_wattage", trackpoint_lap_data[lap_index])
                puts
                
                # puts "Adding #{trackpoint_lap_data[lap_index]}  to the object_stores database."
                # db_activity.object_stores.create( name: "#{trackpoint_lap_data[lap_index]}", payload: trackpoint_lap_data)

              end
              puts "Marking activity as 100% complete.\n\n"
              db_activity.update_attributes({:status => "100", :processed => true})
          end

        else
          puts "Nothing to process in the activity queue.\n"
        end
    end #task

end #namespace