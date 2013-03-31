
namespace :THQ do

  desc "Load unprocessed TCX files for all users, update activity, lap, and trackpoint data."
    task :load_new_activities => :environment do

        require './lib/guppy/lib/guppy.rb'
        
        db_activities = Activity.where(:processed => 0)

        if db_activities.count > 0

          puts "There are #{db_activities.count} activities in the queue.\n"

          db_activities.each do |db_activity|

              device_activity = Guppy::DB.open(db_activity.datafile.path).activities.first # assuming only 1 per garmin file.
              
              puts "Located activity #{device_activity.garmin_activity_id} in \"#{db_activity.name}\"\n"
              db_activity.update_attributes(device_activity.to_hash)

              device_activity.laps.each do |device_lap|
                  puts "\tLocated lap in #{device_activity.garmin_activity_id} with #{device_lap.total_trackpoints} trackpoints.\n"

                  db_lap = db_activity.laps.create(device_lap.to_hash)
                  puts "\tNow processing #{device_lap.total_trackpoints} trackpoints..."

                  device_lap.track_points.each do |track_point|
                      db_lap.trackpoints.create(track_point.to_hash)
                  end
                  puts "done.\n"

              end
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