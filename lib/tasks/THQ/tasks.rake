
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
        
        db = Guppy::Db.open(datafile)

        total_trackpoint_list = []
        db.activities.each do |activity|
          activity.laps.each do |lap|
           total_trackpoint_list << lap.track_points.count
          end
        end
        
        total_trackpoints = total_trackpoint_list.sum.to_f
        trackpoint_progress_percent = (100/total_trackpoints).to_f # for status bar
        trackpoint_progress = (trackpoint_progress_percent*50)

        puts "Loading #{activity_count} activity into the database...\n"
        puts "Processing #{total_trackpoints} trackpoints in #{current_activity.name} from #{datafile}\n"
        puts "Each trackpoint is #{trackpoint_progress_percent} of the whole activity.\n"
        

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
            status: trackpoint_progress
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

            trackpoint_count = 0
            lap.track_points.each do |track_point|

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

              new_lap.first.trackpoints.create([this_track_point])
              trackpoint_count += 1
              if(trackpoint_count == 50)
                status_complete_percent = (current_activity.status + trackpoint_progress )
                puts "Current Activity Status: #{current_activity.status}\n"
                puts "Trackpoint Progress: #{trackpoint_progress}\n"
                puts "Status Complete: #{status_complete_percent}\n\n"
                current_activity.update_attributes({ status: status_complete_percent })
                trackpoint_count = 0
              end
          
            end
                      
          end
          puts "#{current_activity.name} is now active.\n\n"
          current_activity.update_attributes({
            processed: 1,
            status: 100
          })
    end
  end #desc

  desc "Calculate elevation gain and loss for activities in the database"
    task :calculate_elevation_for_existing => :environment do
      return true
      activities = Activity.all

      # Calculate lap altitude loss/gain
      activities.each do |this_activity|
        puts "\nProcessing activity #{this_activity.name}\n"
        total_elevation_loss = 0
        total_elevation_gain = 0
        this_activity.laps.each do |this_lap|

          elevation_loss = 0
          elevation_gain = 0
          this_altitude = 0
          last_altitude = 0

          this_lap.trackpoints.each do |this_trackpoint|
            
            this_altitude = this_trackpoint.altitude.to_i
            # handle initial loop case

            if last_altitude == 0
              last_altitude = this_altitude
            # handle everything else
            else
              if last_altitude < this_altitude
                elevation_gain += (this_altitude - last_altitude)
              else
                elevation_loss += (last_altitude - this_altitude)
              end #if/else
              #puts "VALUES => this_altitude: #{this_altitude}, last_altitude: #{last_altitude}, elevation_gain: #{elevation_gain}, elevation_loss: #{elevation_loss}\n"
              last_altitude = this_altitude

            end #if/else
          end #trackpoint.each
          puts "  Updating lap #{this_lap.id}, gain: #{elevation_gain}, loss: #{elevation_loss}\n"
          total_elevation_loss += elevation_loss
          total_elevation_gain += elevation_gain
          this_lap.update_attributes({:elevation_gain => elevation_gain, :elevation_loss => elevation_loss})
        end #laps.each
          puts "Activity Totals, loss: #{total_elevation_loss}, gain: #{total_elevation_gain}\n\n"
          this_activity.update_attributes({:elevation_gain => total_elevation_gain, :elevation_loss => total_elevation_loss})
      end #activity.each
    end # task

  desc "Calculate Joules for activities and inserts into the database"
    task :calculate_kj => :environment do
      return true
      #activities << Activity.find(6)
      activities = Activity.all
      time = 0
      last_time = 0
      total_activity_joules = 0
      total_lap_joules = 0
      elapsed_time = 0

      activities.each do |this_activity|
        puts "\nProcessing activity #{this_activity.name}\n"
        this_activity.laps.each do |this_lap|
          puts "\tProcessing lap #{this_lap.id}\n"
          this_lap.trackpoints.each do |this_trackpoint|
            time = Time.parse(this_trackpoint.time)
            if(last_time==0)
              last_time=time
            else
              elapsed_time = time - last_time
              joules = this_trackpoint.watts * elapsed_time
              total_activity_joules += joules
              total_lap_joules += joules
              #puts "\t\tWatts: #{this_trackpoint.watts}, Time: #{elapsed_time}, Joules: #{joules}\n"
              this_trackpoint.update_attributes({:joules => joules})
              last_time=time
            end
          end #this_trackpoint
      
          this_lap.update_attributes({:kjoules => total_lap_joules/1000})
          puts "\nTotal Lap kJ: #{this_lap.kjoules}\n"
          total_lap_joules = 0
        end #this_activity.laps   
      
      this_activity.update_attributes({:kjoules => total_activity_joules/1000})
      puts "\nTotal Activity kJ: #{this_activity.kjoules}\n\n"
      total_activity_joules = 0
      end #activities.each
    end # task

  desc "Calculate lap ride time and inserts into the database"
    task :calculate_ride_time => :environment do
     
    return true

      activities = Activity.all
      time = 0
      last_time = 0
      elapsed_time = 0
      distance = 0
      last_distance = 0
      trackpoint_distance = 0
      lap_ride_time = 0
      

      activities.each do |this_activity|
        puts "\nProcessing activity #{this_activity.name}\n"
        this_activity.laps.each do |this_lap|
          puts "\tProcessing lap #{this_lap.id}\n"
          this_lap.trackpoints.each do |this_trackpoint|

            time = Time.parse(this_trackpoint.time)
            distance = this_trackpoint.distance
            
            if(last_time == 0 || last_distance == 0 )
              last_time = time
              last_distance = distance
            else
              elapsed_time = time - last_time
              trackpoint_distance = distance - last_distance

              # only increment time if we changed distance, moved a pedal, or generated a watt.
              if( trackpoint_distance > 0 || this_trackpoint.cadence > 0 || this_trackpoint.watts > 0 )
                lap_ride_time += elapsed_time 
              end
              puts "\t\tElapsed Time: #{elapsed_time}, Trackpoint Distance: #{trackpoint_distance}, Cadence: #{this_trackpoint.cadence}, Watts: #{this_trackpoint.watts}, Lap Ride Time: #{lap_ride_time}\n"
              last_time = time
              last_distance = distance

            end
          end #this_trackpoint
      
          this_lap.update_attributes({:ride_time => lap_ride_time})
          puts "\nLap Ride Time: #{this_lap.ride_time}, Lap Total Time: #{this_lap.total_time}\n"
          lap_ride_time = 0
        
        end #this_activity.laps
           
      end #activities.each
    end # task  
end #namespace