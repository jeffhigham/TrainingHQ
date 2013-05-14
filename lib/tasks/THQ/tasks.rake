
namespace :THQ do

  desc "Load unprocessed TCX files for all users, update activity, lap, and trackpoint data."
    task :load_new_activities => :environment do

        require './lib/guppy/lib/guppy.rb'
        
        db_activities = Activity.where(:processed => 0)
        trackpoint_data = []
        last_trackpoint_distance = 0
        last_trackpoint_altitude = 0
        percent_grade = 0
        trackpoint_percent_grade_rollover = 20 # number of samples to avg for %grade
        trackpoint_percent_grade_values = [0,0] # holds trackpoint_percent_grade_rollover values
        trackpoint_avg_percent_grade = 0 # average %grade based on trackpoint_percent_grade_rollover
        trackpoint_current_time = 0 # trackpoint time in unix time (seconds)

        if db_activities.count > 0
          puts "There are #{db_activities.count} activities in the queue.\n"

          # Process and store activity summary in the database.          
          db_activities.each do |db_activity|
              device_activity = Guppy::DB.open(db_activity.datafile.path).activities.first # assuming only 1 per garmin file.
              puts "Located activity #{device_activity.garmin_activity_id} in \"#{db_activity.name}\"\n"
              db_activity.update_attributes(device_activity.to_hash)

              # Process and store each lap in the database;
              device_activity.laps.each_with_index do |device_lap, lap_index|
                  puts "\tLocated lap in #{device_activity.garmin_activity_id} with #{device_lap.total_trackpoints} trackpoints.\n"
                  db_lap = db_activity.laps.create(device_lap.to_hash)


                  # Process every trackpoint.
                  puts "\tNow processing #{device_lap.total_trackpoints} trackpoints..."
                  trackpoint_data[lap_index] = []

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
                    trackpoint_data [lap_index]<< {
                    #  time_seconds_epoch: Time.parse(trackpoint.time).to_time.to_i,
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

                    last_trackpoint_distance = trackpoint.distance_feet
                    last_trackpoint_altitude = trackpoint.altitude_feet
                    #db_lap.trackpoints.create(track_point.to_hash)
                  end
                  
                  puts "done.\n"

              end
              puts "Adding trackpoint_data to the object_stores database."
              db_activity.object_stores.create( name: "trackpoint_data", payload: trackpoint_data)
              puts "Marking activity as 100% complete."
              db_activity.update_attributes({:status => "100", :processed => true})
          end
        else
          puts "Nothing to process in the activity queue.\n"
        end

  end #desc


  desc "Load manual TCX files"
  
    task :load_manual_activities => :environment do

        require './lib/guppy/lib/guppy.rb'
        device_activity = Guppy::DB.open("./sourcedata/ftp_test.tcx").activities.first
        #db_activity.update_attributes(device_activity.to_hash)
        p device_activity.to_hash
        puts "========================================================================"
        device_activity.laps.each do |device_lap|
                puts "\tLocated lap in #{device_activity.garmin_activity_id} with #{device_lap.total_trackpoints} trackpoints.\n"

                p device_lap.to_hash
                #db_lap = db_activity.laps.create(device_lap.to_hash)
                #puts "\tNow processing #{device_lap.total_trackpoints} trackpoints..."

                #device_lap.track_points.each do |track_point|
                #    db_lap.trackpoints.create(track_point.to_hash)
                #end
                #puts "done.\n"
                device_lap.track_points.collect {|tp| p tp.to_hash }
        end
    end
  
end #namespace