
namespace :THQ do

  desc "Load unprocessed TCX files for all users, update activity, lap, and trackpoint data."
    task :load_new_activities => :environment do

    		require './lib/guppy/lib/guppy.rb'
        unprocessed_activities = Activity.where(:processed => 0)
        activity_count = unprocessed_activities.count
        
# unprocessed_activities.each do |current_activity|
        current_activity = unprocessed_activities.first

        datafile = current_activity.datafile.path
        user_id =  current_activity.user_id
        puts "Loading #{activity_count} into the database...\n"
        puts "Processing #{datafile}\n "

        db = Guppy::Db.open(datafile)
        db.activities.each do |activity|
          
          puts "User Id: #{user_id}"
          puts "Date: #{activity.activity_date}"
          puts "Sport: #{activity.sport}"
          puts "Id:  #{activity.id}"
          puts "Creator: #{activity.creator_name}"
          puts "Unit Id: #{activity.unit_id}"
          puts "Product Id: #{activity.product_id}"
          puts "Author Name: #{activity.author_name}"
          puts "Laps: #{activity.laps.count}"
          puts

          current_activity.update_attributes({
            user_id: user_id,
            activity_date: activity.activity_date,
            sport: activity.sport,
            activityid: activity.id,
            creator_name: activity.creator_name,
            unit_id: activity.unit_id,
            product_id: activity.product_id,
            author_name: activity.author_name,
            status: 50
          })

          activity.laps.each do |lap|
            puts "Lap Time: #{lap.time}"
            puts "Lap Distance: #{lap.distance}"
            puts "Lap Ave Speed: #{lap.ave_speed}"
            puts "Lap Max Speed: #{lap.max_speed}"
            puts "Lap Calories: #{lap.calories}"
            puts "Lap Avg Heart Rate: #{lap.ave_heart_rate}"
            puts "Lap Max Heart Rate: #{lap.max_heart_rate}"
            puts "Lap Ave Watts: #{lap.ave_watts}"
            puts "Lap Max Watts: #{lap.max_watts}"
            puts "Lap Ave Cadence: #{lap.ave_cadence}"
            puts "Lap Max Cadence: #{lap.max_cadence}"
            puts "Lap Intensity: #{lap.intensity}"
           puts

          new_lap = current_activity.laps.create([{
              total_time: lap.time,
              distance: lap.distance,
              ave_speed: lap.ave_speed,
              max_speed: lap.max_speed,
              calories: lap.calories,
              ave_heart_rate: lap.ave_heart_rate,
              max_heart_rate: lap.max_heart_rate,
              ave_watts: lap.ave_watts,
              max_watts: lap.max_watts,
              ave_cadence: lap.ave_cadence,
              max_cadence: lap.max_cadence,
              intensity: lap.intensity
            }])


            bunch_of_track_points = []
            lap.track_points.each do |track_point|
              puts "\t\tTrackpoint: #{track_point.time}"
              puts "\t\tLatitude: #{track_point.latitude}"
              puts "\t\tLongitude: #{track_point.longitude}"
              puts "\t\tCadence: #{track_point.cadence}"
              puts "\t\tWatts: #{track_point.watts}\n"
              puts "\t\tSpeed: #{track_point.speed}\n"
              puts "\t\tHeart Rate: #{track_point.heart_rate}\n"
              puts "\t\tAltidude: #{track_point.altitude}\n"
              puts "\t\tDistance: #{track_point.distance}\n\n"

              this_track_point = {
                 time: track_point.time,
                 latitude: track_point.latitude,
                 longitude: track_point.longitude,
                 cadence: track_point.cadence,
                 watts: track_point.watts,
                 speed: track_point.speed,
                 heart_rate: track_point.heart_rate,
                 altitude: track_point.altitude,
                 distance: track_point.distance
              }

              #new_lap.first.trackpoints.create([this_track_point])
              bunch_of_track_points << this_track_point
          
            end

          

           new_lap.first.trackpoints.create(bunch_of_track_points)
          
          end
          puts "#{current_activity.name} is now active.\n\n"
          current_activity.update_attributes({
            processed: 1,
            status: 100
          })
    end

  end

end