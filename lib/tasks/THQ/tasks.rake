
namespace :THQ do

  # Loads datafiles into the databae and cache. Currently messy / experimental code and needs
  # to be re-written properly.
  desc "Load unprocessed TCX files for all users, update activity, lap, and trackpoint data."
    task :load_new_activities => :environment do

        #require './lib/guppy/lib/guppy.rb'
        
        file_store = ActiveSupport::Cache.lookup_store(:file_store, "/tmp/ramdisk/cache")
        mem_cache_store = ActiveSupport::Cache.lookup_store(:mem_cache_store)
        db_activities = Activity.where(:processed => 0)
        
        if db_activities.count > 0
          puts "There are #{db_activities.count} activities in the queue.\n"
          # Process and store activity summary in the database.          
          db_activities.each do |db_activity|

              
              puts "Crunching datafile for activity named \"#{db_activity.name}\"\n"
              #device_activity = THQ::Datafile.open(db_activity.datafile.path).activities.first # assuming only 1 per garmin file.
              datafile = THQ::Datafile.open(db_activity.datafile.path)
              device_activity = datafile.activities.first
              compressed_activity = datafile.compress
              puts "Performing database updates..."
              puts "\tUpdating \"#{db_activity.name}\" attributes in the database.\n"
              db_activity.update_attributes(device_activity.to_hash)

              device_activity.laps.each_with_index do |device_lap, lap_index|
                  puts "\tAdding lap #{lap_index} to the database.\n"
                  db_lap = db_activity.laps.create(device_lap.to_hash)
              end
              puts "Database updates complete..."
              puts "Populating cache stores..."
              scaled_cache_key = "#{db_activity.id}_scaled"
              puts "\tAdded #{compressed_activity[:trackpoint_data].count} values as #{scaled_cache_key} to the mem_cache_store cache." if 
              mem_cache_store.write(scaled_cache_key, compressed_activity[:trackpoint_data])
              puts "\tAdded #{compressed_activity[:trackpoint_data].count} values as #{scaled_cache_key} to the file_store cache." if 
              file_store.write(scaled_cache_key, compressed_activity[:trackpoint_data])
              puts "\t****************************************************************"

              compressed_activity[:trackpoint_lap_data].each_with_index do |lap_data,lap_index|

                cache_key = "#{db_activity.id}_lap_#{lap_index}"

                puts "\tAdded #{cache_key} to the mem_cache_store cache." if 
                mem_cache_store.write(cache_key, lap_data)
                puts "\tAdded #{cache_key} to the file_store cache." if 
                file_store.write(cache_key, lap_data)
                puts "\t****************************************************************"

                puts "\tAdded #{cache_key}_wattage to the mem_cache_store cache." if
                mem_cache_store.write("#{cache_key}_wattage", compressed_activity[:wattage_data][lap_index])
                puts "\tAdded #{cache_key}_wattage to the file_store cache." if
                file_store.write("#{cache_key}_wattage", compressed_activity[:wattage_data][lap_index])
                puts "\t****************************************************************"
                
                # puts "Adding #{trackpoint_lap_data[lap_index]}  to the object_stores database."
                # db_activity.object_stores.create( name: "#{trackpoint_lap_data[lap_index]}", payload: trackpoint_lap_data)

              end
              puts "Cache stores populated..."
              puts "Marking activity as 100% complete."
              db_activity.update_attributes({:status => "100", :processed => true})
              puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
          end

        else
          puts "Nothing to process in the activity queue.\n"
        end
    end #task

end #namespace