
namespace :THQ do

  require "benchmark"
  # Loads datafiles into the databae and cache. Currently messy / experimental code and needs
  # to be re-written properly.
  desc "Load unprocessed TCX files for all users, update activity, lap, and trackpoint data."
    task :load_new_activities => :environment do

        file_store = nil
        mem_cache_store = nil
        db_activities = nil
        time = Benchmark.realtime do
          file_store = ActiveSupport::Cache.lookup_store(:file_store, "/tmp/ramdisk/cache")
          mem_cache_store = ActiveSupport::Cache.lookup_store(:mem_cache_store)
          db_activities = Activity.where(:processed => 0)
          #db_activities = Activity.where(:id => 51)
        end
        puts "Loaded file_store, mem_cache_store, db_activities Time: #{(time*1000).round(4)}ms (#{time.round(1)}s)."
        
        if db_activities.count > 0
          puts "There are #{db_activities.count} activities in the queue.\n"
          # Process and store activity summary in the database.          
          db_activities.each do |db_activity|
              
              compressed_activity = nil
              total_time = Benchmark.realtime do
                puts "Crunching datafile for activity named \"#{db_activity.name}\"\n"
                datafile = THQ::Datafile.open(db_activity.datafile.path)
                #device_activity = datafile.activities.first # assuming only 1 activity in the datafile.
                device_activity = datafile.activities
                compressed_activity = datafile.compress
                puts "Performing database updates..."
                puts "Updating activity attributes..."
                db_time = Benchmark.realtime do

                  time = Benchmark.realtime do
                    db_activity.update_attributes(device_activity.to_hash)
                  end
                  puts "\"#{db_activity.name}\" updated Time: #{(time*1000).round(4)}ms (#{time.round(1)}s)."

                  puts "Adding laps to the database..."
                  time = Benchmark.realtime do
                    device_activity.laps.each_with_index do |device_lap, lap_index|
                        db_activity.laps.create(device_lap.to_hash)
                        puts "\tAdded lap #{lap_index} to the database.\n"

                    end
                  end
                  puts "Laps complete Time: #{(time*1000).round(4)}ms (#{time.round(1)}s)."
                end
                puts "Database updates complete Time: #{(db_time*1000).round(4)}ms (#{db_time.round(1)}s)."
                
                puts "Populating cache stores..."
                db_activity.blank? and raise "db_activity is not defined!"
                mem_cache_store.blank? and  raise "mem_cache_store is not defined!"
                file_store.blank? and raise "file_store is not defined!"
                #compressed_activity.blank? and raise "compressed_activity is not defined!"
                time = Benchmark.realtime do
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
                    mem_cache_store.write("#{cache_key}_wattage", compressed_activity[:wattage_lap_data][lap_index])
                    puts "\tAdded #{cache_key}_wattage to the file_store cache." if
                    file_store.write("#{cache_key}_wattage", compressed_activity[:wattage_lap_data][lap_index])
                    puts "\t****************************************************************"
                  end

                end

              end  #total_time
              puts "Cache stores populated Time: #{(time*1000).round(4)}ms (#{time.round(1)}s)."
              puts "Marking activity as 100% complete."
              puts "Process Time: #{(total_time*1000).round(4)}ms (#{total_time.round(1)}s)."
              db_activity.update_attributes({:status => "100", :processed => true})
              puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

          end #db_activities

        else
          puts "Nothing to process in the activity queue.\n"
        end
    end #task

end #namespace